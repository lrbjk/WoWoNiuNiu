using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class TerrainEditor : EditorWindow
{
    [MenuItem("TerrainEditor/xixi")]
    private static void OnWindow()
    {
        var window =new TerrainEditor();
        window.Show();
    }
    GameObject prefab;
    bool isPlacing;
    private void OnGUI()
    {
        prefab = EditorGUILayout.ObjectField(prefab, typeof(GameObject), false) as GameObject;

        EditorGUILayout.BeginHorizontal();
        {
            if (prefab != null && GUILayout.Button("Start Placing"))
            {
                StartPlacing();
            }
            if (isPlacing && GUILayout.Button("Stop Placing"))
            {
                StopPlacing();
            }
        }
        EditorGUILayout.EndHorizontal();
    }
    private void StartPlacing()
    {
        isPlacing = true;
        SceneView.duringSceneGui += OnSceneGUI;
    }

    private void StopPlacing()
    {
        isPlacing = false;
        SceneView.duringSceneGui -= OnSceneGUI;
        if (previewInstance != null)
        {
            DestroyImmediate(previewInstance);
        }

    }
    private GameObject previewInstance;
    private void OnSceneGUI(SceneView obj)
    {
        Vector3 position = obj.GetMouseScreenPos();
        //Debug.Log($"{obj.position}  {position}");
        {///转换坐标 
           
            Ray ray = obj.camera.ScreenPointToRay(position);
            RaycastHit hit;
            if (Physics.Raycast(ray.origin,ray.direction, out hit, Mathf.Infinity)&&hit.collider.gameObject!=previewInstance)
            {
                var instantiatePos = hit.collider.transform.position + hit.normal * 3.2f;
                Event e = Event.current;
                if (previewInstance == null)
                {
                    previewInstance = Instantiate(prefab);
                    previewInstance.hideFlags = HideFlags.HideAndDontSave;
                }
                previewInstance.SetActive(true);
                previewInstance.transform.position = instantiatePos;
             
                if (e.type == EventType.KeyDown && e.keyCode == KeyCode.D)
                {
                    Instantiate(prefab, instantiatePos, Quaternion.identity);
                    e.Use();
                }
            }
            else
            {
                if (previewInstance != null) previewInstance.SetActive(false);
            }


        }
        obj.Repaint();








       


        //obj.Repaint();
    }


}
public static class EditorExtendFunc
{
    /// <summary>
    /// 获取鼠标坐标
    /// </summary>
    /// <param name="obj"></param>
    /// <returns></returns>
    public static Vector2 GetMouseScreenPos(this SceneView obj)
    {
     
        var size = obj.camera.ViewportToScreenPoint(Vector3.one) - obj.camera.ViewportToScreenPoint(Vector3.zero);
        var pos = Event.current.mousePosition * (Screen.dpi / 96f);
        pos.y = size.y - pos.y;
        var worldPos = obj.camera.ScreenToWorldPoint(pos);
        return pos;
    }

}