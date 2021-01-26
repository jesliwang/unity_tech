using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Text;
using UnityEngine;
using System.IO;


namespace TAD
{
    public class Utility
    {
        public static float SignedAngle(Vector3 a, Vector3 b)
        {
            var angle = Vector3.Angle(a, b); // calculate angle

            // assume the sign of the cross product's Y component:
            return angle * Mathf.Sign(Vector3.Cross(a, b).y);
        }

        //===================================================
        // 제곱
        // return value의 sign값에 따라 다르다
        //===================================================
        public static float PowToSign(float value, float count)
        {
            float sign = (value < 0) ? -1 : 1;

            return Mathf.Pow(Mathf.Abs(value), count) * sign;
        }

        public static string genKey(List<string> _list, int _keyCnt)
        {
            string result = "";

            if (0 == _keyCnt)
                return "0";

            for (int i = 0; i < _keyCnt - 1; i++)
            {
                result += string.Format("{0},", _list[i]);
            }
            result += string.Format("{0}", _list[_keyCnt - 1]);

            return result;
        }

        public static int GetHashCode(string value)
        {
            int h = 0;
            for (int i = 0; i < value.Length; i++)
                h += value[i] * 31 ^ value.Length - (i + 1);
            return h;
        }



        //==========================================================
        // vDir벡터를 x,y 제한 안에서 랜덤으로 흔든 벡터를 리턴
        //==========================================================
        public static Vector3 ShakeRandomVector(Vector3 vDir, float fX, float fY)
        {
            if (vDir.sqrMagnitude == 0.0f)
            {
                Debug.Log("ㅁㄴㅇㄹ");
            }
            vDir.Normalize();
            Quaternion qRot = Quaternion.LookRotation(vDir);    //Vector3.forward를 vDir로 회전시키는 쿼터니언을 얻음

            float fRandomX = UnityEngine.Random.Range(-fX, fX);
            float fRandomY = UnityEngine.Random.Range(-fY, fY);
            Quaternion qRandomRot = Quaternion.Euler(fRandomX, fRandomY, 0.0f);

            return qRot * qRandomRot * Vector3.forward;
        }

        // 2015.12.26 uppercase 로 검사하도록 변경. !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // 모든 하위 transform 찾아오기
        public static Transform SearchHierarchyForTransform(Transform current, string name)
        {
            if (current.name.ToUpper() == name.ToUpper())
                return current;

            for (int i = 0; i < current.childCount; ++i)
            {
                Transform found = SearchHierarchyForTransform(current.GetChild(i), name);

                if (found != null)
                    return found;
            }

            return null;
        }

        // 2015.12.26 uppercase 로 검사하도록 변경. !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // 모든 하위 transform 찾아오기
        public static Transform SearchHierarchyForTransformByPrefix(Transform current, string prefix)
        {
            if (current.name.ToUpper().IndexOf(prefix.ToUpper()) != -1)
                return current;

            int count = current.childCount;
            for (int i = 0; i < count; ++i)
            {
                Transform found = SearchHierarchyForTransformByPrefix(current.GetChild(i), prefix);

                if (found != null)
                    return found;
            }

            return null;
        }

        // 2015.12.26 uppercase 로 검사하도록 변경. !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // 모든 하위 transform 찾아오기
        public static void SearchAllForTransform(List<Transform> list, Transform current, string name)
        {
            if (current.name.ToUpper() == name.ToUpper())
            {
                list.Add(current);
            }

            int count = current.childCount;
            for (int i = 0; i < count; ++i)
            {
                SearchAllForTransform(list, current.GetChild(i), name);
            }
        }

        // 2015.12.26 uppercase 로 검사하도록 변경. !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        // 모든 하위 transform 찾아오기
        public static void SearchAllForTransformByPrefix(List<Transform> list, Transform current, string prefix)
        {
            if (current.name.ToUpper().IndexOf(prefix.ToUpper()) != -1)
            {
                list.Add(current);
            }

            for (int i = 0; i < current.childCount; ++i)
            {
                SearchAllForTransformByPrefix(list, current.GetChild(i), prefix);
            }
        }

        public static T GetComponentInChildren<T>(Transform gameObj) where T : Component
        {
            T result = null;

            Transform[] arrTransform = gameObj.GetComponentsInChildren<Transform>(true);

            for (int i = 0, fc = arrTransform.Length; i < fc; ++i)
            {
                if (result == null)
                    result = arrTransform[i].GetComponent<T>();

                if (result != null)
                    break;
            }

            return result;
        }

        public static void SetParent(GameObject sourceObject, Transform parent, bool reset = false)
        {
            if (parent != null)
            {
                sourceObject.transform.SetParent(parent);
            }

            if (reset)
            {
                sourceObject.transform.localPosition = Vector3.zero;
                sourceObject.transform.localScale = Vector3.one;
                sourceObject.transform.localRotation = Quaternion.identity;
            }
        }

        public static bool RaycastWithFilter(Vector3 origin, Vector3 direction, out RaycastHit hits, float maxDistance, GameObject[] skipObjs)
        {
            if (skipObjs == null || skipObjs.Length < 1)
            {
                throw new Exception("skip gameobject 가 없는 호출 입니다.");
            }

            int layerMask = -1 - (1 << LayerMask.NameToLayer("SkipObjFilter"));

            int[] layerBackup = new int[skipObjs.Length];

            for (var i = 0; i < skipObjs.Length; ++i)
            {
                layerBackup[i] = skipObjs[i].layer;

                skipObjs[i].layer = LayerMask.NameToLayer("SkipObjFilter");
            }

            bool castResult = Physics.Raycast(origin, direction, out hits, maxDistance, layerMask);

            for (var i = 0; i < skipObjs.Length; ++i)
            {
                skipObjs[i].layer = layerBackup[i];
            }

            return castResult;
        }

        public static Vector3 LegacyDeltaAngle(Transform from, Vector3 to, float xMax, float yMax)
        {
            Vector3 deltaAngle = Vector3.zero;

            Quaternion origin = from.rotation;

            //var targetDir = to - from.position;

            var invers = from.InverseTransformPoint(to);

            deltaAngle.y = Mathf.Atan2(invers.x, invers.z) * Mathf.Rad2Deg;

            if (yMax != 0)
                deltaAngle.y = Mathf.Clamp(deltaAngle.y, -yMax, yMax);

            from.rotation = origin * Quaternion.Euler(deltaAngle);

            invers = from.InverseTransformPoint(to);

            deltaAngle.x = Mathf.Atan2(invers.y, invers.z) * Mathf.Rad2Deg;

            if (xMax != 0)
                deltaAngle.x = Mathf.Clamp(deltaAngle.x, -xMax, xMax);

            return deltaAngle;
        }

        public static Vector3 LegacyDeltaDirAngle(Transform from, Vector3 direction, float xMax, float yMax)
        {
            Vector3 deltaAngle = Vector3.zero;

            Quaternion origin = from.rotation;

            var invers = from.InverseTransformDirection(direction);

            deltaAngle.y = Mathf.Atan2(invers.x, invers.z) * Mathf.Rad2Deg;

            if (yMax != 0)
            {
                deltaAngle.y = Mathf.Clamp(deltaAngle.y, -yMax, yMax);
            }

            from.rotation = origin * Quaternion.Euler(deltaAngle);

            invers = from.InverseTransformDirection(direction);

            deltaAngle.x = Mathf.Atan2(invers.y, invers.z) * Mathf.Rad2Deg;

            if (xMax != 0)
            {
                deltaAngle.x = Mathf.Clamp(deltaAngle.x, -xMax, xMax);
            }

            return deltaAngle;
        }

        public static Vector3 LegacyDeltaDirAngleReverse(Transform from, Vector3 to, float xMax, float yMax)
        {
            Vector3 deltaAngle = Vector3.zero;

            Quaternion origin = from.rotation;

            var invers = from.InverseTransformDirection(to);

            invers = Quaternion.Euler(0, 180, 0) * invers;

            deltaAngle.y = Mathf.Atan2(invers.x, invers.z) * Mathf.Rad2Deg;

            if (yMax != 0)
                deltaAngle.y = Mathf.Clamp(deltaAngle.y, -yMax, yMax);

            from.rotation = origin * Quaternion.Euler(deltaAngle);

            invers = from.InverseTransformDirection(to);

            invers = Quaternion.Euler(180, 0, 0) * invers;

            deltaAngle.x = Mathf.Atan2(invers.y, invers.z) * Mathf.Rad2Deg;

            if (xMax != 0)
                deltaAngle.x = Mathf.Clamp(deltaAngle.x, -xMax, xMax);

            return deltaAngle;
        }

        public static Vector3 LegacyDeltaAngleReverse(Transform from, Vector3 to, float xMax, float yMax)
        {
            Vector3 deltaAngle = Vector3.zero;

            Quaternion origin = from.rotation;

            var invers = from.InverseTransformPoint(to);

            invers = Quaternion.Euler(0, 180, 0) * invers;

            deltaAngle.y = Mathf.Atan2(invers.x, invers.z) * Mathf.Rad2Deg;

            if (yMax != 0)
                deltaAngle.y = Mathf.Clamp(deltaAngle.y, -yMax, yMax);

            from.rotation = origin * Quaternion.Euler(deltaAngle);

            invers = from.InverseTransformPoint(to);

            invers = Quaternion.Euler(180, 0, 0) * invers;

            deltaAngle.x = Mathf.Atan2(invers.y, invers.z) * Mathf.Rad2Deg;

            if (xMax != 0)
                deltaAngle.x = Mathf.Clamp(deltaAngle.x, -xMax, xMax);

            return deltaAngle;
        }

        public static Vector3 DeltaAngle(Transform from, Vector3 to)
        {
            Vector3 deltaAngle = Vector3.zero;

            var targetDir = (to - from.position).normalized;

            var targetRot = Quaternion.Inverse(from.rotation) * Quaternion.LookRotation(targetDir);

            deltaAngle = GetPtoN180Angle(targetRot.eulerAngles);

            return deltaAngle;
        }

        public static Vector3 DeltaAngle2(Transform from, Vector3 to)
        {
            Vector3 deltaAngle = Vector3.zero;

            var dir = (to - from.position).normalized;

            Matrix4x4 mat = from.localToWorldMatrix;
            var invDir = mat.inverse.MultiplyVector(dir);

            deltaAngle.y = Mathf.Atan2(invDir.x, invDir.z) * Mathf.Rad2Deg;

            mat = mat.inverse * Matrix4x4.TRS(Vector3.zero, Quaternion.Euler(deltaAngle), Vector3.one).inverse;
            invDir = mat.inverse.MultiplyVector(dir);

            deltaAngle.x = Mathf.Atan2(invDir.y, invDir.z) * -Mathf.Rad2Deg;

            return deltaAngle;
        }

        public static Vector3 DeltaAngleByDirection(Transform trans, Vector3 direction)
        {
            var targetRot = Quaternion.Inverse(trans.rotation) * Quaternion.LookRotation(direction);

            direction = GetPtoN180Angle(targetRot.eulerAngles);

            return direction;
        }

        public static Vector3 GetPtoN180Angle(Vector3 eularAngle)
        {
            eularAngle.x = eularAngle.x > 180 ? eularAngle.x - 360 : eularAngle.x;
            eularAngle.y = eularAngle.y > 180 ? eularAngle.y - 360 : eularAngle.y;
            eularAngle.z = eularAngle.z > 180 ? eularAngle.z - 360 : eularAngle.z;

            return eularAngle;
        }

        public static float GetPtoN180Angle(float angle)
        {
            angle = angle > 180 ? angle - 360 : angle;

            return angle;
        }

        public static float IncrementTowards(float from, float to, float a)
        {
            if (from != to)
            {
                float dir = Mathf.Sign(to - from); // must n be increased or decreased to get closer to target
                from += a * Time.deltaTime * dir;
                return (dir == Mathf.Sign(to - from)) ? from : to; // if n has now passed target then return target, otherwise return n
            }

            return from;
        }

        public static float IncrementTowards(float from, float to, float time, float maxTime)
        {
            if (from != to)
            {
                float dir = Mathf.Sign(to - from);      // must n be increased or decreased to get closer to target

                float fRatio = time / maxTime;          // 비율

                from += (to - from) * fRatio;

                return (dir == Mathf.Sign(to - from)) ? from : to; // if n has now passed target then return target, otherwise return n
            }

            return from;
        }

        public static float GetCurStoppingDistance(float speed, float maxSpeed)
        {
            return (speed * speed) / (2 * maxSpeed);
        }


        public static Vector3 RotatePointAroundPivot(Vector3 point, Vector3 pivot, Vector3 angles)
        {
            Vector3 dir = point - pivot;
            dir = Quaternion.Euler(angles) * dir;
            point = dir + pivot;
            return point;
        }

        public static Vector3 SimpleBezier(Vector3 p1, Vector3 p2, Vector3 p3, float t)
        {
            t = Mathf.Clamp01(t);

            return Vector3.Lerp(Vector3.Lerp(p1, p2, t), Vector3.Lerp(p2, p3, t), t);
        }

        public static Vector3 SimpleBezier2(Vector3 p1, Vector3 p2, Vector3 p3, float t)
        {
            t = Mathf.Clamp01(t);

            float oneMinusT = 1f - t;

            return oneMinusT * oneMinusT * p1 +
                2f * oneMinusT * t * p2 +
                t * t * p3;
        }

#region CREATE_SERIAL_NUMBER
        private static readonly DateTime Jan1st1970 = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);
        private static long lastTimestamp = -1L;
        private static long sequence = 0;
        //==========================================================
        // 경과 시간
        //==========================================================
        private static long CurrentTime
        {
            get { return (long)(DateTime.UtcNow - Jan1st1970).TotalMilliseconds; }
        }

        //============================================================
        // 시리얼 넘버 생성
        //============================================================
        public static long TimeToSerialNumber()
        {
            var timestamp = CurrentTime;

            if (timestamp < lastTimestamp)
            {
            }

            if (lastTimestamp == timestamp)
            {
                lastTimestamp += sequence;
                ++sequence;
            }

            lastTimestamp = timestamp;

            return lastTimestamp;
        }
#endregion

        public static void DebugDrawPivot(Vector3 target, float size = 5, float duration = 5.0f)
        {
            float halfsize = size * 0.5f;

            Debug.DrawLine(target - Vector3.up * halfsize, target + Vector3.up * halfsize, Color.green, duration);
            Debug.DrawLine(target - Vector3.right * halfsize, target + Vector3.right * halfsize, Color.red, duration);
            Debug.DrawLine(target - Vector3.forward * halfsize, target + Vector3.forward * halfsize, Color.blue, duration);
        }

        public static float PointToLineDistance(Vector3 point, Vector3 lineStart, Vector3 lineDir)
        {
            if (lineDir.sqrMagnitude == 0)
            {
                return 0.0f;
            }

            lineDir.Normalize();

            var toTarget = point - lineStart;

            if (toTarget.sqrMagnitude == 0)
            {
                return 0.0f;
            }

            var projectionLen = Vector3.Dot(lineDir.normalized, toTarget);

            var center = lineStart + lineDir * projectionLen;

            //Debug.DrawLine(lineStart, point, Color.blue);
            //Debug.DrawLine(lineStart, center, Color.green);
            //Debug.DrawLine(point, center, Color.red);

            return (point - center).magnitude;
        }

        //returns -1 when to the left, 1 to the right, and 0 for forward/backward
        public static float AngleDir(Vector3 fwd, Vector3 targetDir, Vector3 up)
        {
            var perp = Vector3.Cross(fwd, targetDir);
            var dir = Vector3.Dot(perp, up);

            if (dir > 0.0f)
            {
                return 1.0f;
            }
            else if (dir < 0.0f)
            {
                return -1.0f;
            }

            return 0.0f;
        }

        //=================================================================
        // 플랫폼 별 Path
        //=================================================================
        public static string PathForDocumentsFile(string filename)
        {
            string strPath = "";
            string path = Application.dataPath;
            strPath = string.Format("{0}/{1}", path, filename);

            return strPath;
        }
    }
}