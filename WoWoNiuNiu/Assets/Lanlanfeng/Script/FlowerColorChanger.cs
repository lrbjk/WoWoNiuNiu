using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FlowerColorChanger : MonoBehaviour
{
    private Material mat1;

    private Material mat2;

    public bool developerMode;

    public float state;

    private float time = 0.5f;

    // void Start(){
    //     mat1 = GetComponent
    // }

    public void setState(float state){
        this.state = state;
        GetComponent<MeshRenderer>().material.SetFloat("_State", state);
        // mat1.SetFloat("_State", state);
        // mat2.SetFloat("_State", state);
    }

    public void setState(){
        GetComponent<MeshRenderer>().material.SetFloat("_State", state);
    }

    void FixedUpdate(){
        if(developerMode){
            if(time <= 0){
                state ++;
                if(state >= 3){
                    state = 0;
                }
                setState();
                time = 0.5f;
            }else{
                time -= Time.fixedDeltaTime;
            }
        }
    }
}
