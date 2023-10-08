using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationComp : MonoBehaviour
{
    public bool isRotate;
    public float rotateSpeed = 1 / 60;
    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {
        Transform trans = this.GetComponent<Transform>();
        trans.Rotate(new Vector3(0, this.rotateSpeed, 0));
    }
}
