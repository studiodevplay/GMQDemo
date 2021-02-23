
using System.IO;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Build.Reporting;
using UnityEditor.Callbacks;
using UnityEngine;

public class Pack : IPreprocessBuildWithReport, IPostprocessBuildWithReport
{
    public int callbackOrder => 0;

    public void OnPreprocessBuild(BuildReport report)
    {
        //string reportPath = report.summary.outputPath;
        //Debug.Log("打包路径为:     "+ reportPath+"--------------");
      
        
#if ONLYTT
        string sourceDirPath = Path.GetFullPath("..")+ "/FunPlay";
        string targerDirPath= Application.dataPath + "/Plugins/iOS/FunPlay";
        if (Directory.Exists(targerDirPath))
        {
            Debug.Log(targerDirPath+"-------文件夹已存在先执行删除命令");
            FileUtil.DeleteFileOrDirectory(targerDirPath);
        }
            
        FileUtil.CopyFileOrDirectory(sourceDirPath, targerDirPath);
        Debug.Log("拷贝 ---Funplay成功-----------");
#elif JOYPAC
        string sourceDirPath = Path.GetFullPath("..") + "/Joypac";
        string targerDirPath = Application.dataPath + "/Plugins/iOS/Joypac";
        if (Directory.Exists(targerDirPath))
        {
            Debug.Log(targerDirPath+"-------文件夹已存在先执行删除命令");
            FileUtil.DeleteFileOrDirectory(targerDirPath);
        }
         
        FileUtil.CopyFileOrDirectory(sourceDirPath, targerDirPath);
        Debug.Log("拷贝 ---Joypac-----------");
#endif




    }

    public void OnPostprocessBuild(BuildReport report)
    {

        Debug.Log("OnPostprocessBuild");

    }
    /// <summary>
    /// Build完成后的回调
    /// </summary>
    /// <param name="target">打包的目标平台</param>
    /// <param name="pathToBuiltProject">包体的完整路径</param>
    [PostProcessBuild(1)]
    public static void AfterBuild(BuildTarget target, string pathToBuiltProject)
    {
        Debug.Log("Build Success  输出平台: " + target + "  输出路径: " + pathToBuiltProject);
        DeleFile(pathToBuiltProject);

    }
    static void DeleFile(string pathToBuiltProject)
    {
#if ONLYTT
        string sourceParh = Application.dataPath + "/Plugins/iOS/FunPlay/Bundle";
        string targetPath = pathToBuiltProject + "/Frameworks/Plugins/iOS/FunPlay/Bundle";

        FileUtil.CopyFileOrDirectory(sourceParh, targetPath);
        Debug.Log("拷贝 --------" + "Bundle成功");

        string targerDirPath = Application.dataPath + "/Plugins/iOS/FunPlay";
        string path = Application.dataPath + "/Plugins/iOS/FunPlay.meta";
        FileUtil.DeleteFileOrDirectory(targerDirPath);
        if (File.Exists(path))
            FileUtil.DeleteFileOrDirectory(path);
        Debug.Log("删除 ---Funplay-------成功-----------");
#elif JOYPAC
     
        string targerDirPath = Application.dataPath + "/Plugins/iOS/Joypac";
        FileUtil.DeleteFileOrDirectory(targerDirPath);
        string path = Application.dataPath + "/Plugins/iOS/Joypac.meta";
        FileUtil.DeleteFileOrDirectory(targerDirPath);
        if (File.Exists(path))
            FileUtil.DeleteFileOrDirectory(path);
        Debug.Log("删除 ---Joypac--------成功-----------");

#endif
    }

     

}
