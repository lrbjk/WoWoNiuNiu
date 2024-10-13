
using UnityEngine;
using UnityEditor;

[ExecuteInEditMode]
public class LockToGrid : MonoBehaviour
{
    public GameObject glassPrefab;
    public float tilesize = 1;
    public Vector3 tileoffset = Vector3.zero;

    private void Update()
    {
        if (!EditorApplication.isPlaying) 
        {
            Vector3 currentPosition = transform.position*10;

            float snappedX = Mathf.Round(currentPosition.x / tilesize) * tilesize + tileoffset.x;
            float snappedY = Mathf.Round(currentPosition.y / tilesize) * tilesize + tileoffset.y;
            float snappedZ = Mathf.Round(currentPosition.z / tilesize) * tilesize + tileoffset.z;
            Vector3 snappedPosition = new Vector3(snappedX, snappedY, snappedZ)/10;
            transform.position = snappedPosition;
        }
    }
}
