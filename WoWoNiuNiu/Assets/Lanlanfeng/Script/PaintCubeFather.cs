using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PaintCubeFather : MonoBehaviour
{
    public PaintCube[] threeD_Cubes;

    public int threeD_Length;

    public PaintCube[] twoD_Cubes;

    public int twoD_Length;

    public bool in3D = false;

    public Vector2 winFlag;

    private bool isWin = false;

    int getRedNum(){
        int count = 0;
        if(in3D){
            for(int i=0; i<threeD_Length; i++){
                if(threeD_Cubes[i].getState() == 1){
                    count ++;
                }
            }
        }else{
            for(int i=0; i<twoD_Length; i++){
                if(twoD_Cubes[i].getState() == 1){
                    count ++;
                }
            }
        }
        return count;
    }

    int getBlueNum(){
        int count = 0;
        if(in3D){
            for(int i=0; i<threeD_Length; i++){
                if(threeD_Cubes[i].getState() == 2){
                    count ++;
                }
            }
        }else{
            for(int i=0; i<twoD_Length; i++){
                if(twoD_Cubes[i].getState() == 2){
                    count ++;
                }
            }
        }
        return count;
    }

    void checkForWin(){
        if(getRedNum() == winFlag.x && getBlueNum() == winFlag.y){
            isWin = true;
        }else{
            isWin = false;
        }
    }

    void Update(){
        if(isWin){

        }
    }
}
