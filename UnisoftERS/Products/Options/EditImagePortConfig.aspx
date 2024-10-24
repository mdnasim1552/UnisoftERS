<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="EditImagePortConfig.aspx.vb" Inherits="UnisoftERS.EditImagePortConfig" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Add/Edit Image Port Devices</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <%--<link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />--%>
    <%--<style type="text/css">--%>
    <%--</style>--%>

    <telerik:RadScriptBlock ID="RadCodeBlock1" runat="server">
            <script type="text/javascript">

        function CloseAndRebind() {
            var oWnd = GetRadWindow();
            oWnd.BrowserWindow.refreshGrid("ImagePort");
            oWnd.close();
        }

        function GetRadWindow() {
            var oWindow = null;
            if (window.radWindow)
                oWindow = window.radWindow;
            else if (window.frameElement.radWindow)
            oWindow = window.frameElement.radWindow;
            return oWindow;
        }    
                

        <%--function CheckForValidPage() {
            var valid = Page_ClientValidate("SaveImagePort");
            if (!valid) {
                $find("<%=ValidationNotification.ClientID%>").show();
            }
        }--%>
            </script>
        </telerik:RadScriptBlock>

</head>
<body>    
    <form id="form1" runat="server">
        <!-- FORM All controls in here -->          
        <asp:HiddenField ID="ImagePortIdHiddenField" runat="server" />
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator2" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="FailedNotification" AutoCloseDelay="0" ShowCloseButton="true" runat="server" VisibleOnPageLoad="false" Skin="Metro" Title="<div class='aspxValidationSummaryHeader'>Please correct the following</div>" ForeColor="Red" Position="Center" />
                      
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <div>
        </div>       

        <div id="FormDiv" runat="server">
            <asp:HiddenField ID="RoomIdHiddenField" runat="server" />  
            <asp:HiddenField ID="OperationHospitalIdHiddenField" runat="server" />  
                        <ContentTemplate>
                            <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="WindowsDiv" Skin="Telerik" />

                            <div id="WindowsDiv">
                                <table style="width: 100%; padding: 10px;">                                
                                    <%--<tr>                                        
                                            <telerik:RadLabel ID="ImagePortLabel" runat="server"></telerik:RadLabel>
                                    </tr>--%>
                                    <tr>
                                        <td>
                                            <telerik:RadLabel ID="PortnameLabel" runat="server" Text="Name:" Skin="Metro" Font-Size="9" Width="85"/>
                                        </td>

                                        <td>
                                            <telerik:RadTextBox ID="PortnameText" runat="server" Style="z-index: 1;" 
                                                Width="200" Skin="Metro"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <telerik:RadLabel ID="MACAddressLabel" runat="server" Text="MAC Address:" Skin="Metro" Font-Size="9"/>
                                        </td>
                                        <td>
                                            <telerik:RadTextBox ID="MACAddressTextBox" runat="server" Style="z-index: 2;" 
                                                Width="200"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <telerik:RadLabel ID="FriendlyNameLabel" runat="server" Text="Friendly Name:" Skin="Metro" Font-Size="9"/>
                                        </td>
                                        <td>
                                            <telerik:RadTextBox ID="FriendlyNameTextBox" runat="server" Style="z-index: 3;" 
                                                Width="200"/>
                                            
                                            &nbsp;<asp:CheckBox ID="DefaultCheckBox" runat="server" CssClass="staticCheckBox" 
                                                Text="Default" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <telerik:RadLabel id="pcnamelabel" runat="server" text="Room Name:" Skin="Metro" Font-Size="9"/>
                                        </td>
                                        <td>
                                            <div style="float: left;">

                                                <telerik:RadComboBox runat="server" ID="RoomMultiColumnComboBox" Skin="Metro" AutoPostBack="false"
                                                    Height="300px" DropDownWidth="165px" width="165px"                                                  
                                                    DataTextField="RoomName" DataValueField="RoomId" EmptyMessage="-Please select a room-">
                                                        <%--<DefaultItem Text="-Please select a room-" Value="-1" />--%>
                                                    </telerik:RadComboBox>
                                                                                                   

                                                <%--<telerik:RadTextBox ID="PCNameTextBox" runat="server" CssClass="pcNameTextBox"></telerik:RadTextBox>--%>
                                                <%--&nbsp;<asp:CheckBox ID="StaticCheckbox" runat="server" CssClass="staticCheckBox" Text="Static" />--%>
                                            </div>
                                            <%--&nbsp;<div style="float: left; padding-top: 3px; padding-left: 15px;"><a class="link_pc" href="javascript:LinkThisPc();">Link this PC</a></div>--%>
                                        </td>
                                    </tr>
                                    <tr>

                                        <tr>
                                            <td>
                                                <telerik:RadLabel ID="CommentsLabel" runat="server" Text="Comments:" CssClass="divTableRow" Skin="Metro" Font-Size="9"/>
                                            </td>

                                            <td>
                                                <telerik:RadTextBox ID="CommentsTextBox" TextMode="MultiLine" Height="75" Width="300"
                                                    runat="server" Style="resize: none; z-index: 4;"/>

                                            </td>
                                        </tr>
                                        <tr>

                                            <td colspan="3" style="padding-top: 50px; text-align: right;"><%-- Change to number of columns --%>
                                                <div id="buttonsdiv" style="height: 10px; padding-top: 6px; vertical-align: central;">
                                                    <telerik:RadButton ID="ImportPortSaveButton" runat="server" Text="Save" Skin="Metro"
                                                        OnClick="ImagePortSaveButton_Click"/>
                                                    <telerik:RadButton ID="AddNewDeviceCancelRadButton" runat="server" Text="Cancel" Skin="Metro"
                                                        OnClientClicked="CloseAndRebind" AutoPostBack="false" />
                                                </div>
                                            </td>
                                        </tr>
                                </table>
                            </div>                            
                       </ContentTemplate>   
        </div>     
    </form>
</body>
</html>
