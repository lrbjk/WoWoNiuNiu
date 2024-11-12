using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PauseManager : MonoBehaviour
{
    public GameObject canvas;

    private bool isActive = false;

    public void Continue(){
        Time.timeScale = 1;
        isActive = false;
    }

    void Update(){
        if(!isActive){
            if(Input.GetKeyDown(KeyCode.Escape)){
                Time.timeScale = 0;
                canvas.SetActive(true);
                isActive = true;
            }
        }
    }
}

