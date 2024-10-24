<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="EditLetterWindow.aspx.vb" Inherits="UnisoftERS.EditLetterWindow" %>

<%@ Register Assembly="DevExpress.Web.v20.1, Version=20.1.10.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<%@ Register Assembly="DevExpress.Web.ASPxRichEdit.v20.1, Version=20.1.10.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web.ASPxRichEdit" TagPrefix="dx" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>

<body>
    <form id="form1" runat="server">
        <div id="ContentDiv">
            <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
                <script type="text/javascript">
                  
                    function CloseEditLetterWindow()
                    {
                        CloseAndRebind();
                    }

                    function CloseAndRebind() {
                        GetRadWindow().BrowserWindow.bookingSaved();
                        GetRadWindow().close();
                    }
                    function GetRadWindow() {
                        var oWindow = null;
                        if (window.radWindow) oWindow = window.radWindow; //Will work in Moz in all cases, including clasic dialog
                        else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow; //IE (and Moz as well)

                        return oWindow;
                    }

                    function OpenPDF() {
                        window.open("DisplayAndPrintPDF.aspx", "_blank");
                    }
                </script>
            </telerik:RadScriptBlock>
             <telerik:RadScriptManager runat="server" />
            <telerik:RadNotification ID="LetterPrintRadNotification" runat="server" VisibleOnPageLoad="false" Height="170px" CssClass="rad-window-popup" ShowCloseButton="true" Skin="Metro" Title="Booking error" AutoCloseDelay="0" />
            <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="900px" Height="700px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0">

                <telerik:RadPane ID="ControlsRadPane" runat="server">
                      <asp:HiddenField runat="server" ID="hdnLetterQueueId"  />
                       <asp:HiddenField runat="server" ID="HiddenAppointmentId"  />
                
                    <telerik:RadButton RenderMode="Lightweight" ID="PrintButton" runat="server" Text="Save & Print" EnableViewState="false" OnClick="SaveAndPrintButton_Click">
                          
                    </telerik:RadButton>
                    <telerik:RadButton RenderMode="Lightweight" ID="CancelButton" runat="server" Text="Close" EnableViewState="false" OnClientClicked="CloseEditLetterWindow">
                       
                    </telerik:RadButton>
                    <dx:ASPxRichEdit ID="ASPxRichEdit1" runat="server" WorkDirectory="~\App_Data\WorkDirectory" OnSaving="RichEdit_Saving" Height="600px" Width="98%">
                        <Settings>
                            <Behavior CreateNew="Hidden" Save="Hidden" Open="Hidden" SaveAs="Hidden" />
                        </Settings>
                    </dx:ASPxRichEdit>
                </telerik:RadPane>

            </telerik:RadSplitter>


        </div>
    </form>
</body>
</html>
