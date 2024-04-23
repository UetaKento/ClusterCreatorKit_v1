using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class P3Rasterize : MonoBehaviour
{
    public Material mat;
    // Start is called before the first frame update
    void Start()
    {
        //Emptyオブジェクトにアタッチして、板ポリゴンを生成する。
        MeshRenderer meshRenderer = gameObject.AddComponent<MeshRenderer>();
        meshRenderer.material = mat;

        Mesh mesh = new Mesh();

        //We create a simple quad in space, so we need for vertices that will become 2 triangles
        mesh.vertices = new Vector3[]
        {
            new Vector3(-0.5f, -0.5f, 0f), //0
            new Vector3(0.5f, -0.5f, 0f),  //1
            new Vector3(0.5f, 0.5f, 0f),   //2
            new Vector3(-0.5f, 0.5f, 0f)   //3
        };

        //We can read/write the color of a vertex, from code or from a 3D modeling software
        mesh.colors = new Color[]  //ここで頂点に色の情報を付与している
        {
            Color.red,      //0
            Color.green,    //1
            Color.blue,     //2
            Color.gray      //3
        };

        //We define the triangles, in this case we share the vertex number 0
        mesh.triangles = new int[]
        {
            0, 2, 1,
            0, 3, 2
        };

        mesh.RecalculateBounds();

        MeshFilter meshFilter = gameObject.AddComponent<MeshFilter>();
        meshFilter.mesh = mesh;
    }

    // Update is called once per frame
    void Update()
    {

    }
}
