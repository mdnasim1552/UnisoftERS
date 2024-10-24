<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Prompt.aspx.vb" Inherits="UnisoftERS.Prompt" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript">
 
        function GetRadWindow() {
            var oWindow = null;
            if (window.radWindow) oWindow = window.radWindow;
            else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow;
            return oWindow;
        }

        function updateANDclose(data) {
            GetRadWindow().BrowserWindow.UpdatedPhraseText(data);
                
        }

        function closeWindow() {
            window.close();
        }
    </script>
    <style>
     #textareaPrompt{
         margin-bottom: 10px;
         margin-top:1px;
     }
     .ActionButton{
         margin-left  :  3px;         
     }
    </style>
     </head>
      <body>
       <form id="form1" runat="server">
          <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
          <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
          <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Skin="Metro" Position="Center" Width="400" Height="150" BorderStyle="Ridge" BorderColor="Red" AutoCloseDelay="0" ShowCloseButton="true" TitleIcon="none" ContentIcon="Warning" EnableShadow="true" EnableRoundedCorners="true" />        
             <div style =" display: flex ; justify-content :center;">
                 <div>
                         <telerik:RadTextBox ID="textareaPrompt" runat="server" TextMode="MultiLine" Height="110px" Width="600px" AutoPostBack="false" Wrap="true" ></telerik:RadTextBox>
                      <div style="display: flex;justify-content: end; ">
                           <telerik:RadButton ID="CopyToBoxButton" CssClass="ActionButton" runat="server" Text="Update" AutoPostBack="true"   Skin="Windows7" ButtonType="SkinnedButton"  OnClick="Phrase_TextChanged"  OnClientClicked="closeWindow">           
                           </telerik:RadButton>  
                           <telerik:RadButton ID="CopyToLibraryButton"  CssClass="ActionButton" runat="server" Text="Cancel" AutoPostBack="true"   Skin="Windows7"  ButtonType="SkinnedButton"   OnClientClicked="closeWindow">
                           </telerik:RadButton>
                     </div>
                 </div>


             </div>
         
       </form>
     </body>
    </html>
