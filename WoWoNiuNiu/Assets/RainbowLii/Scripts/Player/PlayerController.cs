using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Windows;

public class PlayerController : MonoBehaviour
{
    private PlayerInput playerInput;
    public CameraController cameraController;
    private BoxCollider box;
    private Rigidbody rb;
    public float gravity = -9.8f;
    public float moveSpeed = 5;
    public float JumpSpeed = 5;
    // Start is called before the first frame update
    void Start()
    {
        playerInput = new PlayerInput();
        playerInput.Enable();
        rb = GetComponent<Rigidbody>();
        box = GetComponent<BoxCollider>();
    }

    // Update is called once per frame
    void Update()
    {
        box.center = new Vector3(0, 0.87f, 0);
        if (StaticData.is2DCamera)
        {
            box.size = new Vector3(20, 1.6f, 2.38f);
        }
        else
        {
            box.size = new Vector3(2, 1.6f, 2.38f);
        }
        if (playerInput.Player.Move.ReadValue<Vector2>().magnitude >= 0.5f)
        {
            Vector2 input = playerInput.Player.Move.ReadValue<Vector2>();
            How2Move(input);
        }
        else
        {
            rb.velocity = Vector3.zero;
        }
        
        rb.AddForce(Vector3.up * gravity,ForceMode.Force);
    }
    private void FixedUpdate()
    {
        
    }
    private void How2Move(Vector2 input)
    {
        if (StaticData.is2DCamera)
        {
            cameraController.mainCamera.orthographic = true;
            rb.velocity = new Vector2(input.x * moveSpeed,0);
        }
        else
        {
            rb.velocity = new Vector3(input.y,0,-input.x)*moveSpeed;
        }
    }
    
}
