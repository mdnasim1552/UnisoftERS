<%@ Page Language="vb" MasterPageFile="~/Templates/scheduler.master" AutoEventWireup="false" CodeBehind="LetterTemplate.aspx.vb" Inherits="UnisoftERS.LetterTemplate" %>

<%@ Register Assembly="DevExpress.Web.v20.1, Version=20.1.10.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web" TagPrefix="dx" %>

<%@ Register Assembly="DevExpress.Web.ASPxRichEdit.v20.1, Version=20.1.10.0, Culture=neutral, PublicKeyToken=b88d1754d700e49a" Namespace="DevExpress.Web.ASPxRichEdit" TagPrefix="dx" %>

<asp:Content ID="MainBodyContent" ContentPlaceHolderID="BodyContentPlaceHolder" runat="Server">
   <br />
      <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">
            function ShowMessage() {
                alert("please choose letter type");
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

       <asp:HiddenField runat="server" ID="hdnLetterTypeId"  />
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Height="700px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0">
            
            <telerik:RadPane ID="ControlsRadPane" runat="server" >
                    Hospital:&nbsp;<telerik:RadDropDownList ID="HospitalDropDownList" CssClass="filterDDL" runat="server" Width="150" DataTextField="HospitalName" AutoPostBack="true" DataValueField="OperatingHospitalID" OnSelectedIndexChanged="HospitalDropDownList_SelectedIndexChanged" />

                  Available Letter Template:&nbsp;<telerik:RadDropDownList  ID="LetterNameDropdown" CssClass="filterDDL" runat="server" Width="150" DataTextField="LetterName" AutoPostBack="true" DataValueField="LetterTypeId"  OnSelectedIndexChanged="LetterNameDropdown_SelectedIndexChanged" />
                Create Letter Template For:&nbsp;<telerik:RadDropDownList  ID="CreateLetterNameDropdown" CssClass="filterDDL" runat="server" Width="150" DataTextField="LetterName" AutoPostBack="true" DataValueField="UniqueId" OnSelectedIndexChanged="CreateLetterNameDropdown_SelectedIndexChanged" />

         
                <asp:TextBox ID="LetterName" runat="server" Width="150px" style="display:none"></asp:TextBox>
              
                <telerik:RadButton RenderMode="Lightweight" ID="SaveButton" runat="server" Text="Save" OnClick="SaveButton_Click">
                           
                  </telerik:RadButton>
                 <telerik:RadButton RenderMode="Lightweight" ID="Close" runat="server" Text="Close" OnClientClicked="CancelChanges">
                           
                  </telerik:RadButton>
                <telerik:RadButton ID="CloseDocument" ClientIDMode="Static" Text="CloseDocument" runat="server" style="display:none" OnClick="CloseButton_Click" ></telerik:RadButton>
                <dx:ASPxRichEdit ID="ASPxRichEdit1" runat="server" WorkDirectory="~\App_Data\WorkDirectory" OnSaving="RichEdit_Saving" Height="600px" Width="98%" ShowConfirmOnLosingChanges="false">
                    <Settings>
                        <Behavior Save="Hidden" CreateNew="Hidden" Printing="Hidden"   />
                    </Settings>
                </dx:ASPxRichEdit>
            </telerik:RadPane>

        </telerik:RadSplitter>
       

    </div>
</asp:Content>