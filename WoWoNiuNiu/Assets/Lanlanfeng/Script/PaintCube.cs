using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PaintCube : MonoBehaviour
{
    public int state = 0;

    private Material mat;

    public int getState(){
        return state;
    }

    // Start is called before the first frame update
    void Start()
    {
        mat = GetComponent<SpriteRenderer>().material;
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
