using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeDraw : MonoBehaviour
{


        public GameObject start;
        
        public Color red;
        public Color blue;
        private int nowColor;
        
        
        

        void Start()
        {
            
            nowColor = 0;
            start.GetComponent<Position>().DrawColor = blue;
        }

        void OnTriggerEnter(Collider other)
        {
            if (other.gameObject.CompareTag("Player") && start.activeSelf)
            {
                if (nowColor == 0)
                {
                    start.GetComponent<Position>().DrawColor = red;
                    nowColor = 1;
                }
                else if (nowColor == 1)
                {
                    start.GetComponent<Position>().DrawColor = blue;
                    nowColor = 0;
                }
            }
        }
    }


