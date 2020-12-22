using UnityEngine;
using System.Collections;
 
public class EyeTrackBlink : MonoBehaviour
{
 
    public float eyeMaxOffset = 0.3f; // max amount the eyes are clamped to
    public Renderer eyeRend; // eyeball renderer
    public Renderer lidRend; // eyelid renderer
    public float blinkingTextureAmount = 4f; // amount of frames of blinking animation
    public float blinkTimer = 4f; // timer for when to blink again
    public float blinkTransition = 0.05f;
    Vector2 eyeOffset;
    Vector2 eyelidOffset;
    float blinkOffset;
    float blinkTimerR;
 
    void Start()
    {
        blinkTimerR = blinkTimer;
        blinkOffset = 1 / blinkingTextureAmount;
        eyelidOffset = new Vector2(0,0);
        lidRend.materials[1].SetTextureScale("_MainTex", new Vector2(blinkOffset, 1));
 
    }
    void Update()
    {
        blinkTimerR -= Time.deltaTime;
        if (blinkTimerR <= 0.0f)
        {
            StartCoroutine(Blink());
 
        }
 
        eyeOffset = new Vector2(transform.localPosition.x, -transform.localPosition.y);
           // clamp so the eye doesnt disappear  
        if(eyeOffset.x < -eyeMaxOffset || eyeOffset.x > eyeMaxOffset)
        {
            eyeOffset.x = Mathf.Clamp(eyeOffset.x, -eyeMaxOffset, eyeMaxOffset);
        }
         if(eyeOffset.y < -eyeMaxOffset || eyeOffset.y > eyeMaxOffset)
        {
            eyeOffset.y = Mathf.Clamp(eyeOffset.y, -eyeMaxOffset, eyeMaxOffset);
        }
       // send offset to shader
        eyeRend.material.SetTextureOffset("_MainTex", eyeOffset);
 
    }
 
    IEnumerator Blink()
    {
        // animating 1 - 2 - 3 - 4 - 3 - 1, if you have more or less blinking animation frames, add or delete them here
        blinkTimerR = blinkTimer + Random.Range(-1,1); // slight randomisation to the blinking
        lidRend.materials[1].SetTextureOffset("_MainTex", eyelidOffset); //1
        yield return new WaitForSeconds(blinkTransition);
        lidRend.materials[1].SetTextureOffset("_MainTex", new Vector2(eyelidOffset.x + blinkOffset, 0)); //2
        yield return new WaitForSeconds(blinkTransition);
        lidRend.materials[1].SetTextureOffset("_MainTex", new Vector2(eyelidOffset.x + (blinkOffset * 2), 0)); //3
        yield return new WaitForSeconds(blinkTransition);
        lidRend.materials[1].SetTextureOffset("_MainTex", new Vector2(eyelidOffset.x + (blinkOffset * 3), 0)); //4
        yield return new WaitForSeconds(blinkTransition);
        lidRend.materials[1].SetTextureOffset("_MainTex", new Vector2(eyelidOffset.x + (blinkOffset * 2), 0)); //3
        yield return new WaitForSeconds(blinkTransition);
        lidRend.materials[1].SetTextureOffset("_MainTex", eyelidOffset); //1
 
 
    }
}