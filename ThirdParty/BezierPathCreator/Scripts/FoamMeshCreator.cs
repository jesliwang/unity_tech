﻿using System.Collections.Generic;
using UnityEngine;
using PathCreation.Utility;

namespace PathCreation.Examples
{
    public class FoamMeshCreator : PathSceneTool
    {
        [Header("Foam settings")]
        public float foamWidth = .4f;
        [Range(0, .5f)]
        //public float thickness = .15f;
        public bool flattenSurface;

        [Header("Material settings")]
        public Material foamMaterial;
        //public Material undersideMaterial;
        public float textureTiling = 1;

        MeshFilter meshFilter;
        MeshRenderer meshRenderer;

        protected override void PathUpdated()
        {
            if (pathCreator != null)
            {
                AssignMeshComponents();
                AssignMaterials();
                meshFilter.mesh = CreateFoamMesh();;
            }
        }


        Mesh CreateFoamMesh()
        {
            Vector3[] verts = new Vector3[path.NumVertices * 8];
            Vector2[] uvs = new Vector2[verts.Length];
            Vector3[] normals = new Vector3[verts.Length];

            int numTris = 2 * (path.NumVertices - 1) + ((path.isClosedLoop) ? 2 : 0);
            int[] foamTriangles = new int[numTris * 3];
            //int[] underFoamTriangles = new int[numTris * 3];
            //int[] underFoamTriangles = new int[numTris * 2 * 3];

            int vertIndex = 0;
            int triIndex = 0;

            // Vertices for the top of the foam are layed out:
            // 0  1
            // 8  9
            // and so on... So the triangle map 0,8,1 for example, defines a triangle from top left to bottom left to bottom right.
            int[] triangleMap = { 0, 8, 1, 1, 8, 9 };
            int[] sidesTriangleMap = { 4, 6, 14, 12, 4, 14, 5, 15, 7, 13, 15, 5 };

            bool usePathNormals = !(path.space == PathSpace.xyz && flattenSurface);

            for (int i = 0; i < path.NumVertices; i++)
            {
                //Vector3 localUp = (usePathNormals) ? Vector3.Cross(path.tangents[i], path.normals[i]) : path.up;
                Vector3 localUp = Vector3.Cross(path.tangents[i], path.normals[i]);
                Vector3 localRight = (usePathNormals)?path.normals[i]:Vector3.Cross(localUp,path.tangents[i]);

                // Find position to left and right of current path vertex
                Vector3 vertSideA = path.vertices[i] - localRight * Mathf.Abs(foamWidth) -transform.position;
                Vector3 vertSideB = path.vertices[i] + localRight * Mathf.Abs(foamWidth) - transform.position;

                // Add top of foam vertices
                verts[vertIndex + 0] = vertSideA;
                verts[vertIndex + 1] = vertSideB;
                // Add bottom of foam vertices
                verts[vertIndex + 2] = vertSideA/* - localUp * thickness*/;
                verts[vertIndex + 3] = vertSideB/* - localUp * thickness*/;

                // Duplicate vertices to get flat shading for sides of foam
                verts[vertIndex + 4] = verts[vertIndex + 0];
                verts[vertIndex + 5] = verts[vertIndex + 1];
                verts[vertIndex + 6] = verts[vertIndex + 2];
                verts[vertIndex + 7] = verts[vertIndex + 3];


                // Set uv on y axis to path time (0 at start of path, up to 1 at end of path)
                uvs[vertIndex + 0] = new Vector2(0, path.times[i]);
                uvs[vertIndex + 1] = new Vector2(1, path.times[i]);

                // Top of foam normals
                normals[vertIndex + 0] = localUp;
                normals[vertIndex + 1] = localUp;

                // Bottom of foam normals
                normals[vertIndex + 2] = -localUp;
                normals[vertIndex + 3] = -localUp;

                // Sides of foam normals
                normals[vertIndex + 4] = -localRight;
                normals[vertIndex + 5] = localRight;
                normals[vertIndex + 6] = -localRight;
                normals[vertIndex + 7] = localRight;


                // Set triangle indices
                if (i < path.NumVertices - 1 || path.isClosedLoop)
                {
                    for (int j = 0; j < triangleMap.Length; j++)
                    {
                        foamTriangles[triIndex + j] = (vertIndex + triangleMap[j]) % verts.Length;
                        // reverse triangle map for under foam so that triangles wind the other way and are visible from underneath
                        //underFoamTriangles[triIndex + j] = (vertIndex + triangleMap[triangleMap.Length - 1 - j] + 2) % verts.Length;
                    }
                    //for (int j = 0; j < sidesTriangleMap.Length; j++)
                    //{
                    //    underFoamTriangles[triIndex * 2 + j] = (vertIndex + sidesTriangleMap[j]) % verts.Length;
                    //}

                }

                vertIndex += 8;
                triIndex += 6;
            }


            Mesh mesh = new Mesh();
            mesh.vertices = verts;
            mesh.uv = uvs;
            mesh.normals = normals;
            mesh.subMeshCount = 3;
            mesh.SetTriangles(foamTriangles, 0);
            //mesh.SetTriangles(underFoamTriangles, 1);
            //mesh.SetTriangles(underFoamTriangles, 2);
            mesh.RecalculateBounds();

            return mesh;
        }


        // Add MeshRenderer and MeshFilter components to this gameobject if not already attached
        void AssignMeshComponents()
        {
            // Find/creator mesh holder object in children
            string meshHolderName = "Mesh Holder";
            Transform meshHolder = transform.Find(meshHolderName);
            if (meshHolder == null) {
                meshHolder = new GameObject(meshHolderName).transform;
                meshHolder.transform.parent = transform;
                meshHolder.transform.localPosition = Vector3.zero;
                //meshHolder.transform.localPosition = transform.position;
            }

            //meshHolder.transform.position = Vector3.zero;
            meshHolder.transform.rotation = Quaternion.identity;

            // Ensure mesh renderer and filter components are assigned
            if (!meshHolder.gameObject.GetComponent<MeshFilter>())
            {
                meshHolder.gameObject.AddComponent<MeshFilter>();
            }
            if (!meshHolder.GetComponent<MeshRenderer>())
            {
                meshHolder.gameObject.AddComponent<MeshRenderer>();
            }

            meshRenderer = meshHolder.GetComponent<MeshRenderer>();
            meshFilter = meshHolder.GetComponent<MeshFilter>();
        }

        void AssignMaterials()
        {
            if (foamMaterial != null /*&& undersideMaterial != null*/)
            {
                meshRenderer.sharedMaterials = new Material[] { foamMaterial/*, undersideMaterial, undersideMaterial*/ };
                meshRenderer.sharedMaterials[0].mainTextureScale = new Vector3(1, textureTiling);
                meshRenderer.sharedMaterials[0].SetFloat("_WaveTile", textureTiling);
            }
        }

    }
}