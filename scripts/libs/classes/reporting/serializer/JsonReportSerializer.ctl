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
    int slash = strrpos(fileName, "/");
    if (slash < 0)
      slash = strrpos(fileName, "\\");

    if (slash < 0)
      return true;

    string dir = substr(fileName, 0, slash);
    return ensureDir(dir);
  }

  private bool ensureDir(string dir)
  {
    if (dir == "" || isdir(dir))
      return true;

    int slash = strrpos(dir, "/");
    if (slash < 0)
      slash = strrpos(dir, "\\");

    if (slash > 0)
    {
      string parent = substr(dir, 0, slash);
      if (!ensureDir(parent))
        return false;
    }

    mkdir(dir);
    return isdir(dir);
  }
};
