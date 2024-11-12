using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PauseManager : MonoBehaviour
{
    public GameObject canvas;

    private Animator canvasAnim;

    // private bool isActive = false;

    void Start(){
        canvasAnim = canvas.GetComponent<Animator>();
    }

    public void Continue(){
        // Time.timeScale = 1;
        canvasAnim.Play("PauseQuit");
        // isActive = false;
    }

    

    void Update(){
        if(!canvas.active){
            if(Input.GetKeyDown(KeyCode.Escape)){
                // Time.timeScale = 0;
                GameObject.FindWithTag("Finish").GetComponent<CameraController>().enabled = false;
                GameObject.FindWithTag("Player").GetComponent<PlayerController>().enabled = false;
                canvas.SetActive(true);
                // isActive = true;
            }
        }
    }
}

