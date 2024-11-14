using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StartDraw : MonoBehaviour
{


        public GameObject start;

        

        void Start()
        {
            start.SetActive(false);
            
        }

        void OnTriggerEnter(Collider other)
        {
            // 检查碰撞的是哪个GameObject
            if (other.gameObject.CompareTag("Player"))
            {
                start.SetActive(true);
            }
        }
    }


