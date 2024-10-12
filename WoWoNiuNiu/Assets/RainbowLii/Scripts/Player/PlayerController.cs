using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Windows;

public class PlayerController : MonoBehaviour
{
    private PlayerInput playerInput;
    public CameraController cameraController;
    public GameObject Model;
    private BoxCollider box;
    private Rigidbody rb;
    private bool canClimb;
    private bool isClimbing;
    public float gravity = -9.8f;
    public float moveSpeed = 5;
    public float jumpSpeed = 5;
    public float climbSpeed = 3;
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

        Vector2 input = playerInput.Player.Move.ReadValue<Vector2>();

        if (input.magnitude >= 0.5f)
        {
            How2Move(input);
        }
        else
        {
            rb.velocity = Vector3.zero;
        }

        if (!isClimbing)
        {
            rb.AddForce(Vector3.up * gravity, ForceMode.Force);
        }
    }

    private void How2Move(Vector2 input)
    {
        if (StaticData.is2DCamera)
        {
            cameraController.mainCamera.orthographic = true;

            if (isClimbing)
            {
                // 攀爬逻辑
                Climbing(input);
            }
            else
            {
                // 水平移动
                rb.velocity = new Vector2(input.x * moveSpeed, 0);
                Vector3 moveDirection = rb.velocity.normalized;
                if (moveDirection.x != 0)
                {
                    Quaternion targetRotation = Quaternion.LookRotation(new Vector3(moveDirection.x, 0, 0));
                    Model.transform.rotation = Quaternion.Slerp(Model.transform.rotation, targetRotation, turnSpeed * Time.deltaTime);
                }
            }
        }
        else
        {
            Vector3 moveDirection = new Vector3(input.y, 0, -input.x);
            if (moveDirection != Vector3.zero)
            {
                Quaternion targetRotation = Quaternion.LookRotation(new Vector3(moveDirection.x, 0, moveDirection.z));
                Model.transform.rotation = Quaternion.Slerp(Model.transform.rotation, targetRotation, turnSpeed * Time.deltaTime);
            }
            rb.velocity = moveDirection * moveSpeed;
        }
    }

    private void Climbing(Vector2 input)
    {
        // 攀爬逻辑
        rb.useGravity = false; // 禁用重力
        rb.velocity = new Vector2(0, input.x * climbSpeed); // 使用输入的Y值进行上下攀爬

        Vector3 moveDirection = rb.velocity.normalized;
        if (moveDirection.x != 0)
        {
            // 攀爬时面向垂直方向
            Vector3 climbDirection = new Vector3(0, moveDirection.x, 0);
            Quaternion targetRotation = Quaternion.LookRotation(Vector3.forward, climbDirection); // 保持前方为Z轴
            Model.transform.rotation = Quaternion.Slerp(Model.transform.rotation, targetRotation, turnSpeed * Time.deltaTime);
        }

        // 停止攀爬
        if (input.x == 0)
        {
            isClimbing = false;
            rb.useGravity = true; // 恢复重力
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.layer == 6)
        {
            canClimb = true;
            isClimbing = true;
        }
    }

    private void OnCollisionExit(Collision collision)
    {
        if (collision.gameObject.layer == 6)
        {
            canClimb = false;
            isClimbing = false;
            rb.useGravity = true; // 离开可攀爬区域时恢复重力
        }
    }
}

