using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EndDraw : MonoBehaviour
{


        public GameObject start;
        

    

        void Start()
        {
            
        }

        void OnTriggerEnter(Collider other)
        {
            // 检查碰撞的是哪个GameObject
            if (other.gameObject.CompareTag("Player"))
            {
                start.SetActive(false);
            }

        }
    }


