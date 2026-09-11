// $License: NOLICENSE
//--------------------------------------------------------------------------------
/**
  @file $relPath
  @copyright $copyright
  @author ipapakri
*/

//--------------------------------------------------------------------------------
// Libraries used (#uses)
#uses "classes/reporting/ReportModel"
#uses "classes/reporting/ReportSerializer"

//--------------------------------------------------------------------------------
// Variables and Constants

//--------------------------------------------------------------------------------
/**
  jsonEncode of ReportModel.toMapping() written as UTF-8 JSON.
*/
class JsonReportSerializer : ReportSerializer
{
//--------------------------------------------------------------------------------
//@public members
//--------------------------------------------------------------------------------

  //------------------------------------------------------------------------------
  /** The Default Constructor.
  */
  public JsonReportSerializer()
  {
  }

  public bool write(shared_ptr<ReportModel> model, string fileName)
  {
    if (model == nullptr || fileName == "")
      return false;

    if (!ensureParentDir(fileName))
      return false;

    string json = jsonEncode(model.toMapping());
    file fd = fileOpen(fileName, "w");

    if ((int)fd <= 0)
    {
      DebugTN(__FILE__, __FUNCTION__, __LINE__, "Could not open JSON file", fileName);
      return false;
    }

    fileWrite(fd, json);
    fileClose(fd);
    return isfile(fileName);
  }

//--------------------------------------------------------------------------------
//@protected members
//--------------------------------------------------------------------------------

//--------------------------------------------------------------------------------
//@private members
//--------------------------------------------------------------------------------

  private bool ensureParentDir(string fileName)
  {
    int slash = lastPathSeparator(fileName);

    if (slash < 0)
      return true;

    string dir = substr(fileName, 0, slash);
    return ensureDir(dir);
  }

  private bool ensureDir(string dir)
  {
    if (dir == "" || isdir(dir))
      return true;

    int slash = lastPathSeparator(dir);

    if (slash > 0)
    {
      string parent = substr(dir, 0, slash);
      if (!ensureDir(parent))
        return false;
    }

    mkdir(dir);
    return isdir(dir);
  }

  /**
    CTRL has no strrpos. Walk backwards with substr() to find the last
    directory separator.
  */
  private int lastPathSeparator(string path)
  {
    int last = -1;

    for (int i = strlen(path) - 1; i >= 0; i--)
    {
      string character = substr(path, i, 1);
      if (character == "/" || character == "\\")
        return i;
    }

    return last;
  }
};
