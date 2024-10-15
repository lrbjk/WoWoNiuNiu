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
    // box0: 普通爬行; box1：向上爬行
    public BoxCollider box;
    private Rigidbody rb;
    private bool canClimb;
    public bool isClimbing;
    public float gravity = -9.8f;
    public float moveSpeed = 5;
    public float jumpSpeed = 5;
    public float climbSpeed = 3;
    public float turnSpeed = 90;

    // 纠正因子 fixUper/_forward[0]为2D模式，fixUper/_forward[1]为3D模式
    public float[] fixUper;
    public int[] _forward;

    // Start is called before the first frame update
    void Start()
    {
        playerInput = new PlayerInput();
        playerInput.Enable();
        rb = GetComponent<Rigidbody>();
        // box = GetComponent<BoxCollider>();
    }

    // Update is called once per frame
    void Update()
    {

        
        if (StaticData.is2DCamera)
        {
            if(!isClimbing){
                box.size = new Vector3(20, 1.266826f, 1.489801f);
            }else{
                box.size = new Vector3(20, 2.11f, 1.489801f);
            }
            
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
            //rb.AddForce(Vector3.up * gravity, ForceMode.Force);
            rb.useGravity = true;

            // 在攀爬模式下，会更改模型碰撞体的中心位置。
            box.center = new Vector3(-5.53998f, 0.70341f, -0.1639f);

            // 把更改_forward[]的能力封存在isClimbing为否的条件下
            if(input.x >= 0){
                if(StaticData.is2DCamera){
                    _forward[0] = 1;
                }
            }else{
                if(StaticData.is2DCamera){
                    _forward[0] = -1;
                }
            }
        }else{
            if(StaticData.is2DCamera){
                box.center = new Vector3(0, 0.14f, 0);
            }
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

        if(_forward[0] == 1){
            rb.velocity = new Vector2(0, input.x * climbSpeed); // 使用输入的Y值进行上下攀爬
        }else{
            rb.velocity = new Vector2(0, input.x * -climbSpeed); // 使用输入的Y值的反向进行上下攀爬
        }
        

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

            Vector3 climbDirection;

            Quaternion targetRotation;

            // 旋转时在X轴发生偏转
            if(_forward[0] == 1){
                climbDirection = new Vector3(-90f, 0, 0);
                targetRotation = Quaternion.LookRotation(Vector3.up, climbDirection); // 保持前方为Z轴

                Model.transform.rotation = Quaternion.Slerp(Model.transform.rotation, targetRotation, turnSpeed * Time.deltaTime);

            }else{
                // climbDirection = new Vector3(-90f, 0, 180f);
                // targetRotation = Quaternion.LookRotation(Vector3.down, climbDirection); // 保持前方为Z轴

                Model.transform.rotation = Quaternion.Euler(new Vector3(-90, 0, 270));
            }

            
            // 因为碰撞体之间存在间距，在这里添加一个纠正因子。
                Model.transform.position = new Vector3(Model.transform.position.x + fixUper[0] * _forward[0], Model.transform.position.y, Model.transform.position.z);

            
        }
    }

    private void OnCollisionExit(Collision collision)
    {
        if (collision.gameObject.layer == 6)
        {
            canClimb = false;
            isClimbing = false;
            rb.useGravity = true; // 离开可攀爬区域时恢复重力

            // 旋转时切换碰撞体

            // 旋转时在X轴发生偏转
            Vector3 climbDirection = new Vector3(0, 0, 0);
            Quaternion targetRotation = Quaternion.LookRotation(Vector3.forward, climbDirection); // 保持前方为Z轴
            Model.transform.rotation = Quaternion.Slerp(Model.transform.rotation, targetRotation, turnSpeed * Time.deltaTime);

            // 因为碰撞体之间存在间距，在这里添加一个纠正因子。
            // Model.transform.position = new Vector3(Model.transform.position.x - fixUper[0] * _forward[0], Model.transform.position.y, Model.transform.position.z);
            Model.transform.localPosition = new Vector3(0,0,0);
        }
    }
}

