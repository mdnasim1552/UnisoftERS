<%@ Page Language="vb"  MasterPageFile="~/Templates/scheduler.master" AutoEventWireup="false" CodeBehind="EditLetter.aspx.vb" Inherits="UnisoftERS.EditLetter" %>
<%@ Register Assembly="DevExpress.Web.v20.1, Version=20.1.10.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<%@ Register Assembly="DevExpress.Web.ASPxRichEdit.v20.1, Version=20.1.10.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web.ASPxRichEdit" TagPrefix="dx" %>

<asp:Content ID="MainBodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">
   <br />
      <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            function ShowMessage() {
                alert("please choose letter type");
            }

            function OpenPDF() {
                window.open('DisplayAndPrintPDF.aspx', "_blank");
            }

            function CancelChanges() {
                if (confirm('Close document, unsaved changes will be lost?')) {
                    document.getElementById('CloseDocument').click();
                }
            }
        </script>
    </telerik:RadScriptBlock>
    <div id="ContentDiv">
        <telerik:RadNotification ID="LetterPrintRadNotification" runat="server" VisibleOnPageLoad="false" Height="170px" CssClass="rad-window-popup" ShowCloseButton="true" Skin="Metro" Title="Booking error" AutoCloseDelay="0" />
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Height="700px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0">
 
            <telerik:RadPane ID="ControlsRadPane" runat="server" >
               
                <asp:HiddenField runat="server" ID="hdnLetterQueueId"  />
                   
                              <telerik:RadButton RenderMode="Lightweight" ID="PrintButton" runat="server" Text="Save & Print" EnableViewState="false" OnClick="SaveAndPrintButton_Click">
                       
                    </telerik:RadButton>
                  <telerik:RadButton RenderMode="Lightweight" ID="CancelButton" runat="server" Text="Close" EnableViewState="false" OnClientClicked="CancelChanges" >
                                
                  </telerik:RadButton>
                <telerik:RadButton ID="CloseDocument" ClientIDMode="Static" Text="CloseDocument" runat="server" style="display:none" OnClick="CloseDocument_Click" ></telerik:RadButton>
                
                    
                     <telerik:RadLabel  Text="Edit Reason:"  runat="server" ID="EditReasonLabel"  Visible="false"></telerik:RadLabel>
                    <telerik:RadDropDownList  ID="LetterEditReasonDropdown" Visible ="false" CssClass="filterDDL" runat="server" Width="150" DataTextField="Reason" AutoPostBack="true" DataValueField="LetterEditReasonId"  />

                     <telerik:RadTextBox   runat="server" Width="250px" ID="LetterEditReasonText" Visible ="false"></telerik:RadTextBox>
               

                <dx:ASPxRichEdit ID="ASPxRichEdit1" runat="server" WorkDirectory="~\App_Data\WorkDirectory" OnSaving="RichEdit_Saving" Height="600px" Width="98%" ShowConfirmOnLosingChanges="false" >
                    <Settings>
                        <Behavior CreateNew="Hidden" Save="Hidden" Open="Hidden" SaveAs="Hidden"    />
                    </Settings>
                </dx:ASPxRichEdit>
            </telerik:RadPane>

        </telerik:RadSplitter>
       

    </div>
</asp:Content>