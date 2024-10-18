using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlowerColorChanger : MonoBehaviour
{
    private Material[] mat1;

    private Material mat2;

    public bool developerMode;

    public float state;

    private float time = 0.5f;

    private float swapNum = 1f;

    private bool newOut = true;

    void Start(){
        mat1 = GetComponent<MeshRenderer>().materials;
        // mat2 = GetComponent<MeshRenderer>()[1].material;
        time = 2f;
        swapNum = 1f;
        newOut = true;
    }

    public void setState(float state){
        this.state = state;
        mat1[0].SetFloat("_State", state);
        mat1[1].SetFloat("_State", state);
        newOut = true;
        // mat1.SetFloat("_State", state);
        // mat2.SetFloat("_State", state);
    }

    public void setState(){
        mat1[0].SetFloat("_State", state);
        mat1[1].SetFloat("_State", state);
        newOut = true;
    }

    void FixedUpdate(){
        if(developerMode){
            if(time <= 0){
                state ++;
                if(state >= 3){
                    state = 0;
                }
                setState();
                time = 2f;
            }else{
                time -= Time.fixedDeltaTime;
            }
        }

        if(newOut){
            mat1[0].SetFloat("_SwapTime", swapNum);
            mat1[1].SetFloat("_SwapTime", swapNum);
            swapNum -= Time.fixedDeltaTime * 5f;
            if(swapNum <= 0){
                mat1[0].SetFloat("_SwapTime", 0);
                mat1[1].SetFloat("_SwapTime", 0);
                newOut = false;
                swapNum = 1f;
            }
        }
    }
}
