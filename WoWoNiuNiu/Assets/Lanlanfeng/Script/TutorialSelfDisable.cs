using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TutorialSelfDisable : MonoBehaviour
{
    public void OnDisable(){
        this.gameObject.SetActive(false);
    }
}
