#if UNITY_EDITOR
using System.IO;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEngine;

public class Pack : IPreprocessBuildWithReport, IPostprocessBuildWithReport
{
    public int callbackOrder => 0;

    public void OnPreprocessBuild(BuildReport report)
    {
        Debug.Log("打包前");

        string dir1 = Path.GetFullPath("..")+ "/FunPlay";
    }

    public void OnPostprocessBuild(BuildReport report)
    {
        Debug.Log("打包后");
    }
}
#endif