using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;




namespace UnityStandardAssets.Utility
{
    [RequireComponent(typeof(Text))]

    public class FPSCounter : MonoBehaviour
    {
        float deltaTime = 0.0f;
        private Text m_Text;

        private void Start()
        {
            m_Text = GetComponent<Text>();
        }

        void Update()
        {
            deltaTime += (Time.deltaTime - deltaTime) * 0.1f;
            float msec = deltaTime * 1000.0f;
            float fps = 1.0f / deltaTime;
            m_Text.text = string.Format("{0:0.0} ms ({1:0.} fps)", msec, fps);

        }

        /*  void OnGUI()
          {

              float msec = deltaTime * 1000.0f;
              float fps = 1.0f / deltaTime;
              m_Text.text = string.Format("{0:0.0} ms ({1:0.} fps)", msec, fps);

          }
      */
    }
}
