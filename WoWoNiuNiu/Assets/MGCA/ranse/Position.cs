using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;

[ExecuteInEditMode]
public class Position : MonoBehaviour
{
    public Material material;
    public Vector3 startPoint;
    private float startTime; 
    public float traceDuration = 5.0f;  
    private List<Vector3> pathPoints = new List<Vector3>();
    public int textureSize = 256; // 纹理大小  
    public Texture2D pathTexture; 
    public GameObject woniu;
    
    
    // Start is called before the first frame update
    void Start()
    {
        startTime = Time.time;  
        pathTexture = new Texture2D(textureSize, textureSize, TextureFormat.RGBA32, false);
        pathTexture.filterMode = FilterMode.Point;
        pathTexture.wrapMode = TextureWrapMode.Repeat;
        Color[] colors = new Color[textureSize * textureSize];
        for (int i = 0; i < colors.Length; i++)
        {
            colors[i] = Color.black;
        }
        pathTexture.SetPixels(colors);
        pathTexture.Apply();
    }

    // Update is called once per frame
    void Update()
    {
        if (material)  
        {  
            int x = (int)(transform.position.x - startPoint.x + textureSize /2.0f);
            int y = (int)(transform.position.z - startPoint.z + textureSize / 2.0f);
            if (x >= 0 && x < textureSize && y >= 0 && y < textureSize)
            {
                        Debug.Log(x + "," + y);
                        pathTexture.SetPixel(x, y, Color.white);
            }  
            pathTexture.Apply();
            material.SetTexture("_cross", pathTexture);
            material.SetFloat("_textureSize",textureSize);
            material.SetVector("_startPoint",startPoint);
            material.SetVector("_woniu_position",woniu.transform.position);
        }  
    }
    
}

