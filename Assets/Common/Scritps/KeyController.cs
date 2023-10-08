using UnityEngine;

public class KeyController : MonoBehaviour
{
    private float horizontalInput;
    private float verticalInput;
    private float speed = 10f;
    public void Update()
    {
        this.horizontalInput = Input.GetAxis("Horizontal");
        this.verticalInput = Input.GetAxis("Vertical");

        this.transform.Translate(Vector3.right * this.horizontalInput * Time.deltaTime * speed);
        this.transform.Translate(Vector3.forward * this.verticalInput * Time.deltaTime * speed);
    }
}