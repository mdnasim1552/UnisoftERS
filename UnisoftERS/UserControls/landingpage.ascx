<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="landingpage.ascx.vb" Inherits="UnisoftERS.landingpage" ClassName="landingpage" %>
<style type="text/css">
     .contentGreen {
        background-image: -webkit-linear-gradient(top, #87CB63 0%, #5DA437 100%);
        background-image: -moz-linear-gradient(top, #87CB63 0%, #5DA437 100%);
        background-image: -ms-linear-gradient(top, #87CB63 0%, #5DA437 100%);
        background-image: -o-linear-gradient(top, #87CB63 0%, #5DA437 100%);
        background-image: linear-gradient(top, #87CB63 0%, #5DA437 100%);
        border-bottom: 20px solid #5DC206;
    }

    .contentBlue {
        background-image: -webkit-linear-gradient(top, #d9e6f2 0%, #a0c0de 100%);
        background-image: -moz-linear-gradient(top, #d9e6f2 0%, #a0c0de 100%);
        background-image: -ms-linear-gradient(top, #d9e6f2 0%, #a0c0de 100%);
        background-image: -o-linear-gradient(top, #d9e6f2 0%, #a0c0de 100%);
        background-image: linear-gradient(top, #d9e6f2 0%, #a0c0de 100%);
        border-bottom: 20px solid #5DC206;
    }
     .contentOrange {
        background-image: -webkit-linear-gradient(top, #FFBA75 0%, #FF7F00 100%);
        background-image: -moz-linear-gradient(top, #FFBA75 0%, #FF7F00 100%);
        background-image: -ms-linear-gradient(top, #FFBA75 0%, #FF7F00 100%);
        background-image: -o-linear-gradient(top, #FFBA75 0%, #FF7F00 100%);
        background-image: linear-gradient(top, #FFBA75 0%, #FF7F00 100%);
        border-bottom: 20px solid #5DC206;
    }
     .contentRed {
        background-image: -webkit-linear-gradient(top, #F35A6D 0%, #C20E24 100%);
        background-image: -moz-linear-gradient(top, #F35A6D 0%, #C20E24 100%);
        background-image: -ms-linear-gradient(top, #F35A6D 0%, #C20E24 100%);
        background-image: -o-linear-gradient(top, #F35A6D 0%, #C20E24 100%);
        background-image: linear-gradient(top, #F35A6D 0%, #C20E24 100%);
        border-bottom: 20px solid #5DC206;
    }
</style>


<div style="width: 100%; height: auto;">
    <div style="margin-left: 0px;">        
        <table id="tableTiles" runat="server" cellspacing="0" cellpadding="0" border="0">
            <tr>
                <td id="tdLeftHeading" class="divTileHeading" style="color: #666666; width: 400px;" runat="server" visible="false" ><b>Dashboard</b></td>
                <td id="tdRightHeading" class="divTileHeading" style="color: #666666;" runat="server"><b><%If Not CBool(Session("isERSViewer")) And 1 = 2 Then%>Utilities<%End If%></b></td>
            </tr>

            <tr>
                <td style="vertical-align: top;">
                    <table id="tableLeft" runat="server" cellspacing="0" cellpadding="0" border="0">
                        <tr>
                            <td id="tdSubLeftHeading" class="divTileHeading" colspan="3" runat="server"><%If Not CBool(Session("isERSViewer")) And 1 = 2 Then%>Quickly access key components<%End If%></td>
                        </tr>
                        <tr>
                            <td colspan="5">
                                <telerik:radcontenttemplatetile id="RadContentTemplateTile1" runat="server" Skin="Metro" width="380px" height="120px">
                                                    <ContentTemplate>
                                                        <table runat="server" style="margin-left: 5px; margin-top: 20px; font-weight: normal; color: white;" cellpadding="0" cellspacing="0">
                                                            <tr>
                                                                <td>Logged on</td>
                                                                <td style="width: 8px"></td>
                                                                <td>
                                                                    <asp:Label ID="lblLoggedOn" runat="server" Text=""  ForeColor="#ffffcc"/>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td>System version</td>
                                                                <td></td>
                                                                <td><asp:Label ID="lblVersion" runat="server" ForeColor="#ffffcc" ></asp:Label></td>
                                                            </tr>
                                                            <tr>
                                                                <td>Permissions</td>
                                                                <td></td>
                                                                <td><asp:Label ID="lblPermissions" runat="server"  ForeColor="#ffffcc"></asp:Label></td>
                                                            </tr>
                                                            <tr style="visibility:hidden;">
                                                                <td>Hospital number</td>
                                                                <td></td>
                                                                <td><asp:Label ID="lblHospitalNumber" runat="server"  ForeColor="#ffffcc"></asp:Label></td>
                                                            </tr>
                                                            <tr>
                                                                <td>Database name</td>
                                                                <td></td>
                                                                <td><asp:Label ID="lblDatabaseName" runat="server"  ForeColor="#ffffcc"></asp:Label></td>
                                                            </tr>
                                                            <tr>
                                                                <td colspan="3">
                                                                    <div id="LicenceExpiryDiv" runat="server" visible="false" style="margin-left: 5px; margin-top: 20px; font-weight: bold; font-size: 20px; color: white;">
                                                                        <asp:Label ID="LicenceExpiryLabel" runat="server"></asp:Label>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </table>
                                                    </ContentTemplate>
                                                    <PeekTemplate>
                                                        <div id="LicencePeekTemplateDiv" runat="server">
                                                            <div style="margin-left: 5px; margin-top: 10px; font-weight: bold; font-size: 20px; color: white;" >
                                                                <asp:Label ID="LicenceLabel" runat="server" Visible="false"></asp:Label>
                                                            </div>
                                                        </div>
                                                    </PeekTemplate>
                                                    <PeekTemplateSettings Animation="None"  ShowInterval="0" CloseDelay="0" AnimationDuration="0"
                                                        ShowPeekTemplateOnMouseOver="false" HidePeekTemplateOnMouseOut="true" />
                                                </telerik:radcontenttemplatetile>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <telerik:radicontile width="120px" height="120px" id="radTileScheduler" runat="server"
                                    imageurl="~/Images/dashboard-icons/scheduler.png" imageheight="60px" imagewidth="70px" cssclass="radTileBgDarkBlue"
                                    navigateurl="~/Products/Scheduler.aspx"
                                    title-text="Scheduler" skin="Metro">
                                                </telerik:radicontile>
                            </td>
                            <td>
                                <telerik:radicontile width="120px" height="120px" id="radTilePASDownload" runat="server"
                                    imageurl="~/Images/dashboard-icons/download-to-pas.png" imageheight="60px" imagewidth="70px" cssclass="radTileBgDarkBlue"
                                    title-text="PAS Download" skin="Metro"
                                    onclientclicked="OpenPopUpWindow('PASDownload')">
                                                </telerik:radicontile>
                            </td>
                            <td>
                                <telerik:radicontile width="120px" height="120px" id="radTileReports" runat="server"
                                    imageurl="~/Images/dashboard-icons/view-reports.png" imageheight="60px" imagewidth="70px" backcolor="#f5c020" cssclass="radTileBgYellow"
                                    title-text="Reports" skin="Metro">
                                                </telerik:radicontile>
                            </td>
                        </tr>
                    </table>
                </td>
                <td style="vertical-align: top;">
                    <table id="tableRight" runat="server" cellspacing="0" cellpadding="0">
                        <tr>
                            <td class="divTileHeading" colspan="3">Configure and personalise this product</td>
                        </tr>
                        <tr>
                            <td>
                                <telerik:radicontile width="120px" height="120px" id="radTileUserSettings" runat="server" cssclass="radTileBgLightBlue"
                                    imageurl="~/Images/dashboard-icons/user-settings-2.png" imageheight="60px" imagewidth="70px"
                                    navigateurl="~/Products/Options/OptionsMain.aspx?node=UserSettings"
                                    title-text="Your settings" skin="Metro">
                                                </telerik:radicontile>
                            </td>
                            <td>
                                <telerik:radicontile width="120px" height="120px" id="radTileSysSettings" runat="server" 
                                     imageheight="60px" imagewidth="70px"
                                    navigateurl="~/Products/Options/OptionsMain.aspx?node=SystemSettings"
                                    title-text="System settings" skin="Metro">
                                                </telerik:radicontile>
                            </td>
                            <td>
                                <telerik:radicontile width="120px" height="120px" id="radTileExpSettings" runat="server" cssclass="radTileBgLightBlue"
                                    imageurl="~/Images/dashboard-icons/export-settings.png" imageheight="60px" imagewidth="70px"
                                    navigateurl="~/Products/Options/OptionsMain.aspx?node=ExportSettings"
                                    title-text="Export settings" skin="Metro">
                                                </telerik:radicontile>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <telerik:radicontile width="120px" height="120px" id="radTileDBSettings" runat="server" cssclass="radTileBgLightBlue"
                                    imageurl="~/Images/dashboard-icons/database-settings.png" imageheight="60px" imagewidth="70px"
                                    navigateurl="~/Products/Options/OptionsMain.aspx?node=DatabaseSettings"
                                    title-text="Database settings" skin="Metro">
                                                </telerik:radicontile>
                            </td>
                            <td>
                                <telerik:radicontile width="120px" height="120px" id="radTileAdminUtils" runat="server" cssclass="radTileBgLightBlue"
                                    imageurl="~/Images/dashboard-icons/admin-utils.png" imageheight="60px" imagewidth="70px"
                                    navigateurl="~/Products/Options/OptionsMain.aspx?node=AdminUtilities"
                                    title-text="Admin utilities" skin="Metro">
                                                </telerik:radicontile>
                            </td>
                            <td>
                                <telerik:radicontile width="120px" height="120px" id="radTileUserMaint" runat="server" cssclass="radTileBgLightBlue"
                                    imageurl="~/Images/dashboard-icons/user-maintenance.png" imageheight="60px" imagewidth="70px"
                                    navigateurl="~/Products/Options/OptionsMain.aspx?node=UserMaintenance"
                                    title-text="User maintenance" skin="Metro">
                                                </telerik:radicontile>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <telerik:radcontenttemplatetile id="FAQTile" runat="server" backcolor="#9b58b5" width="250px" height="120px" cssclass="radTileBgViolet"
                                    skin="BlackMetroTouch">
                                                    <ContentTemplate>
                                                        <table style="margin-left: 5px; margin-top: 10px; color: white;" cellpadding="0" cellspacing="0">
                                                            <tr>
                                                                <td>
                                                                    <img src="../Images/dashboard-icons/knowledge-base.png" alt="Knowledge base" />
                                                                </td>
                                                                <td style="width: 8px"></td>
                                                                <td>
                                                                    <asp:Label ID="FAQTileText" runat="server" Text="Knowledge management portal" />
                                                                </td>
                                                            </tr>
                                                        </table>
                                                        <div class="rtileTitle" style="margin-left: 10px;">
                                                            Knowledge base
                                                        </div>
                                                    </ContentTemplate>
                                                    <PeekTemplate>
                                                        <div id="Div1" runat="server" style="height: 100%;height:120px;" class="radTileBgViolet">
                                                            <div style="margin-left: 5px; margin-top: 10px; font-size: 15px; color: white;">
                                                                Knowledge management inc FAQs, help files and user manuals that enable you to use the system with more ease
                                                            </div>
                                                        </div>
                                                    </PeekTemplate>
                                                    <PeekTemplateSettings Animation="Slide" ShowInterval="3600000" CloseDelay="2000" AnimationDuration="1000"
                                                        ShowPeekTemplateOnMouseOver="true" HidePeekTemplateOnMouseOut="true" />
                                                </telerik:radcontenttemplatetile>
                            </td>
                            <td>
                                <telerik:radicontile backcolor="#9b58b5" width="120px" height="120px" id="SupportTile" runat="server" cssclass="radTileBgViolet"
                                    imageurl="~/Images/dashboard-icons/product-support-1.png" imageheight="60px" imagewidth="70px"
                                    title-text="Product support" skin="BlackMetroTouch">
                                                </telerik:radicontile>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </div>
</div>
