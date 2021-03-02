using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectRendererSortingOrder : MonoBehaviour
{
    public enum GroundType
    {
        //Background,
        //Foreground,
        Background,
        Unit,
        Zero
    }
    public enum OrderType
    {
        SingleValue,
        SameMaterials,
    }
    int index = 0;
    public GroundType groundType = GroundType.Background;
    public OrderType orderType = OrderType.SameMaterials;

    //public List<Renderer> ignoreRenderer = new List<Renderer>();          //타겟만 돌게 수정
    public List<Renderer> targetRenderer = new List<Renderer>();
    void Start()
    {
        if (SortingOrderData.SortingOrderDatas.Contains(this.gameObject.name))
        {
            index = SortingOrderData.SortingOrderDatas.IndexOf(this.gameObject.name);
        }
        else
        {
            index = SortingOrderData.SortingOrderDatas.Count;
            SortingOrderData.SortingOrderDatas.Add(this.gameObject.name);
        }
        int order = 0;
        int startOrder = -30000;
        switch (groundType)
        {
            case GroundType.Unit:
                startOrder = -30000;
                break;
            case GroundType.Background:
                startOrder = -10000;
                break;
            default:
                startOrder = 0;
                break;
        }

        //Renderer[] renderers = GetComponentsInChildren<Renderer>();           //타겟만 돌게 수정 
        List<Material> materials = new List<Material>();
        List<int> cacheOrders = new List<int>();
        
        //foreach (Renderer renderer in renderers)
        foreach (Renderer renderer in targetRenderer)
        {
            if (renderer == null) continue;

            if (renderer.sharedMaterial == null) continue;
            //if (ignoreRenderer.Contains(renderer))continue;                   //타겟만 돌게 수정

            //string shaderName = renderer.sharedMaterial.shader.name;
            //if (!shaderName.Contains("CF/Background") && !shaderName.Contains("CF/Character"))
            //{
            //    continue;
            //}

            if (orderType == OrderType.SameMaterials)
            {
                int scaleCheckResult = 0;
                if (0 > renderer.gameObject.transform.localScale.x * renderer.gameObject.transform.localScale.y * renderer.gameObject.transform.localScale.z)
                    scaleCheckResult = 1;

                if (!materials.Contains(renderer.sharedMaterial))
                {
                    materials.Add(renderer.sharedMaterial);
                    int num = startOrder + index + order;
#if UNITY_EDITOR
                    if (num > 32767)
                    {
                        NDebug.LogError("Graphic : [경고] 할당 가능한 최대 SortingOrder 값을 넘었습니다. <" + renderer.gameObject.name + ">");
                    }
#endif
                    SetSortingOrder(renderer, num + scaleCheckResult);
                    cacheOrders.Add(num);
                    order += 1 + scaleCheckResult;
                }
                else
                {
                    SetSortingOrder(renderer, cacheOrders[materials.IndexOf(renderer.sharedMaterial)] + scaleCheckResult);
                }
            }
            else if(orderType == OrderType.SingleValue)
            {
                SetSortingOrder(renderer, startOrder + index + order);
                order++;
            }
        }
        materials.Clear();
        cacheOrders.Clear();
    }
    void SetSortingOrder(Renderer _renderer, int _order)
    {
        _renderer.sortingOrder = _order;
#if UNITY_EDITOR
        //string _sortingOrder = _order.ToString();
        //NDebug.Log(_renderer + _sortingOrder);
#endif
    }
#if UNITY_EDITOR
    private void OnEnable()
    {
        Start();

        foreach (Renderer renderer in targetRenderer)
        {
            //meshFilter.mesh.bounds = bounds;
            if (null == renderer)
            {
                NDebug.LogError(gameObject.name + "   Object Renderer Sorting Order에 Renderer를 등록해주세요.(Graphic)");
            }
        }
    }
    //private void OnDrawGizmosSelected()
    //{
    //    foreach (Renderer renderer in targetRenderer)
    //    {
    //        //meshFilter.mesh.bounds = bounds;
    //        if (null == renderer)
    //        {
    //            NDebug.LogError("Object Renderer Sorting Order에 Renderer를 등록해주세요.");
    //        }
    //    }
    //}
#endif
}
