using System.Collections;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using UnityEngine;

public class postprocess : MonoBehaviour
{
    public Material material;
    public GameObject water;
    
    private Camera cam;

    // Start is called before the first frame update
    void OnEnable()
    {
        cam =GetComponent<Camera>();
    }

    // Update is called once per frame
    void Update()
    {
        Debug.Log(StaticData.is2DCamera);
        if(StaticData.is2DCamera)
        GetNearClipPos();
    }

    void GetNearClipPos()
    {
        Vector4[] points = new Vector4[4];
        points[0] = cam.ViewportToWorldPoint(new Vector3(0.0f,0.0f,cam.nearClipPlane));
        points[1] = cam.ViewportToWorldPoint(new Vector3(1.0f,0.0f,cam.nearClipPlane));
        points[2] = cam.ViewportToWorldPoint(new Vector3(0.0f,1.0f,cam.nearClipPlane));
        points[3] = cam.ViewportToWorldPoint(new Vector3(1.0f,1.0f,cam.nearClipPlane));
        
        material.SetVectorArray("_Points", points);
        material.SetFloat("_Depth",water.transform.position.y);
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if (StaticData.is2DCamera)
        {
            Graphics.Blit(source, destination, material);
            Debug.Log("111");
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

}
