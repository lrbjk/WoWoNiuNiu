using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;

public class Position : MonoBehaviour
{

    public RenderTexture rt;
    private RenderTexture rt0;

    public Texture2D drawImg;
    public Texture2D defalutImg;
    public Material stand_mat;
    public Material stand_mat2;
    public Vector3 startPoint;
    public GameObject woniu;

    public Texture Noise;
    private Vector3 pos0;
    public float shiscale = 10f;
    public Color DrawColor;

    public GameObject Change;
    
    


    // Start is called before the first frame update
    void OnEnable()
    {
        pos0 = woniu.transform.position - new Vector3(20, 20, 20);
        DrawDefault();
        rt0 = new RenderTexture(Screen.width, Screen.height, 0, rt.graphicsFormat);
        rt0.Create();
        Vector2 ab = new Vector2(rt.width, rt.height) / shiscale;
        stand_mat2.SetVector("_textureSize",ab);
        DrawColor = Change.GetComponent<ChangeDraw>().blue;
        
    }

    public void DrawDefault()
    {
        RenderTexture.active = rt;
        GL.PushMatrix();
        GL.LoadPixelMatrix(0,rt.width,rt.height,0);

        Rect rect = new Rect(0, 0, Screen.width, Screen.height);

        Graphics.DrawTexture(rect, defalutImg);

        GL.PopMatrix();

        RenderTexture.active = null;
    }

    public void Draw(float x, float y)
    {
        Graphics.Blit(rt, rt0);

        RenderTexture.active = rt;
        GL.PushMatrix();
        GL.LoadPixelMatrix(0, rt.width, rt.height, 0);

        x -= (int)(drawImg.width  * 0.5f);
        y -= (int)(drawImg.height * 0.5f);

        Rect rect = new Rect(x, y, drawImg.width,drawImg.height );

        Vector4 SO = new Vector4();
        SO.x = rect.x / rt.width;
        SO.y = 1 - rect.y / rt.height;
        SO.z = rect.width / rt.width;
        SO.w = rect.height / rt.height;
        SO.y -= SO.w;

        stand_mat.SetTexture("_SourceTex", rt0);
        stand_mat.SetVector("_SourceUV", SO);
        stand_mat.SetTexture("_Noise", Noise);
        stand_mat.SetVector("_Color",DrawColor);

        Graphics.DrawTexture(rect, drawImg, stand_mat);

        GL.PopMatrix();
        RenderTexture.active = null;
    }

    // Update is called once per frame
    void Update()
    {

        if (stand_mat != null)
        {
            if (pos0 != woniu.transform.position)
            { 
                float x = (woniu.transform.position.x * shiscale - startPoint.x  + rt.width / 2.0f);
                float y = (-woniu.transform.position.z * shiscale - startPoint.z  + rt.height / 2.0f);
                
                if (x >= 0 && x < rt.width && y >= 0 && y < rt.height)
                {
   
                    Draw(x, y);
                    pos0 = woniu.transform.position;
                }
            }
        }

    }
}

