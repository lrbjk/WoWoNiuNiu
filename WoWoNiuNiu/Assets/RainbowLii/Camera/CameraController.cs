using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{
    public CinemachineVirtualCamera twoD_Camera;
    public CinemachineVirtualCamera threeD_Camera;
    public Camera mainCamera;
    private bool is2DCamera;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetKeyDown(KeyCode.G))
        {
            if (is2DCamera)
            {
                twoD_Camera.Priority = 0;
                threeD_Camera.Priority = 10;
                is2DCamera = false;
                StaticData.is2DCamera = false;
                mainCamera.orthographic = false;
            }
            else
            {
                threeD_Camera.Priority = 0;
                twoD_Camera.Priority = 10;
                is2DCamera = true;
                StaticData.is2DCamera = true;
                //mainCamera.orthographic = true;
            }
        }
    }
}
