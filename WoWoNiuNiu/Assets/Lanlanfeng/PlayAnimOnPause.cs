using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayAnimOnPause : MonoBehaviour
{
    public void ToyamaKasumi(){
        GameObject.FindWithTag("Finish").GetComponent<CameraController>().enabled = true;
        GameObject.FindWithTag("Player").GetComponent<PlayerController>().enabled = true;
        gameObject.SetActive(false);
    }
}
