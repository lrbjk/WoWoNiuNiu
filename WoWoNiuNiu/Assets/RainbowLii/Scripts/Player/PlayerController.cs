using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Windows;

public class PlayerController : MonoBehaviour
{
    private PlayerInput playerInput;
    public CameraController cameraController;
    public GameObject Model;
    private BoxCollider box;
    private Rigidbody rb;
    public float gravity = -9.8f;
    public float moveSpeed = 5;
    public float JumpSpeed = 5;
    public float turnSpeed = 90;
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
            Model.transform.rotation = new Quaternion(0,0,0,0);
            rb.velocity = new Vector2(input.x * moveSpeed,0);
        }
        else
        {
            Vector3 moveDirection = rb.velocity.normalized;

            // 检查移动方向是否有效，避免零向量的旋转
            if (moveDirection != Vector3.zero)
            {
                // 目标旋转是面向移动方向的旋转
                Quaternion targetRotation = Quaternion.LookRotation(new Vector3(moveDirection.x, 0, moveDirection.z));

                // 平滑地旋转到目标方向
                Model.transform.rotation = Quaternion.Slerp(Model.transform.rotation, targetRotation, turnSpeed * Time.deltaTime);
            }
            rb.velocity = new Vector3(input.y, 0, -input.x) * moveSpeed;
        }
    }
    
}
