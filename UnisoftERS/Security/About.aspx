<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Security_About" CodeBehind="About.aspx.vb"  %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title>About Solus Endoscopy</title>
    <link href="../Styles/Site.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../Scripts/Global.js"></script>
    <style type="text/css">
        .rcbSlide {
            z-index: 999999 !important;
        }
    </style>
</head>
<body style="overflow:hidden;" >
    <form id="mainForm" runat="server" >
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <script type="text/javascript">
        </script>
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Skin="Web20" Style="z-index: 9999" />
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="500px" Height="450px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7" Style="overflow:hidden;">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Height="450px" Scrolling="None">

                <div style="float:left;position: absolute;">
                    <img src="../Images/dashboard-icons/blue-man_trans.png" height="450" width="169"  />
                </div>
                
                <div id="FormDiv" runat="server" style=" vertical-align: top;float:left;width:393px;height:100%;padding-left:107px; " >
                    
                    <asp:Label class="divWelcomeMessage" ID="lblWelcomeMessage" runat="server" Text="Solus Endoscopy" />
                    <asp:Label ID="lblLicensed" runat="server" />
                    <div style="padding-top:20px;">
                       
                        <telerik:RadTabStrip ID="SearchTabStrip" runat="server" Skin="Default" SelectedIndex="0" MultiPageID="RMSearch"   BorderWidth="0">
                            <Tabs>
                                <telerik:RadTab Text="Web Server" />
                                <telerik:RadTab Text="DB Server" />
                                <telerik:RadTab Text="Support" />
                            </Tabs>
                        </telerik:RadTabStrip>


                        <div style="border:1px solid lightgray;border-width: 0px 0px 0px 1px;float:left;width:0px;height:30px;"></div>
                        <div id="Div3" runat="server" style="border:1px solid lightgray;border-width: 1px 1px 0px 0px;height:226px;padding:10px;overflow:hidden;
                                                            overflow-y:auto; border-radius: 0px 10px 0px 80px;" class="radTileBgLightGray">

                        <telerik:RadMultiPage ID="RMSearch" runat="server" SelectedIndex="0" >
                            <telerik:RadPageView ID="RadPageView1" runat="server" >
                                
                                    <asp:Label ID="lblWeb" runat="server" />
                                
                            </telerik:RadPageView>

                            <telerik:RadPageView ID="RadPageView2" runat="server" >
                                    <asp:Label ID="lblDB" runat="server" />

                            </telerik:RadPageView>

                            <telerik:RadPageView ID="RadPageView3" runat="server">
                                <div style="text-align:center;padding-top:50px;">
                                    <asp:Label ID="lblSupportHotline" runat="server" Text="" /> <br /><br />
                                    <a href="http://www.hd-clinical.com" target="_blank">www.hd-clinical.com</a> <br />
                                    <a href="http://www.hd-clinical.com/support" target="_blank">www.hd-clinical.com/support</a>
                                </div>
                            </telerik:RadPageView>
                        </telerik:RadMultiPage>

                        </div>
                        <div style="border:1px solid lightgray;border-width: 1px 0px 0px 0px;width:335px;float:right;"></div>


                        <div style="position: fixed;bottom: 20px; right: 20px;">
                            <telerik:RadButton ID="RadButton1" runat="server" Text="Close" Skin="Windows7" AutoPostBack="false" OnClientClicked="CloseWindow" />
                        </div>
                    </div>

                </div>


            </telerik:RadPane>

        </telerik:RadSplitter>


    </form>
</body>
</html>
