using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewBehaviourScript : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        string str1 = "\"${CONFIGURATION_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/Frameworks/UnityFramework.framework()/\"\n";
        string str2 = "\"Frameworks\"";
        string RunScript = "cd" + str1 + "if [[ -d" + str2 + "]]" + ';' + "then rm -fr Frameworks fi";

        Debug.Log(RunScript);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
