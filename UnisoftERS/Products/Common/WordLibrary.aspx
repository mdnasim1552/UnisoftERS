<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Common_WordLibrary" CodeBehind="WordLibrary.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Phrase library</title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />

    <telerik:RadScriptBlock ID="RadScriptBlock1" runat="server">
        <script type="text/javascript">

            function phraseDelete() {
                let phraseValue
                let selectedListBox
                var tabStrip = $find("<%=AlertTabStrip.ClientID%>");
                var generalListBox = $find("<%=GeneralListBox.ClientID%>");
                var personalListBox = $find("<%=PersonalListBox.ClientID%>");
                var personalListBoxItem = personalListBox.get_selectedItem();
                let tabCount = tabStrip.get_tabs().get_count();
                if (personalListBoxItem) {
                    phraseValue = personalListBoxItem.get_value()
                    selectedListBox = personalListBox
                }
                else if (tabCount == 2 && generalListBox.get_selectedItem()) {
                    phraseValue = generalListBox.get_selectedItem().get_value()
                    selectedListBox = generalListBox
                }

                if (phraseValue != null) {
                    deletePhrase(phraseValue, selectedListBox);
                }
                else {
                    var notification = $find("<%=RadNotification1.ClientID%>");
                    notification.set_text("Please select a Phrase")
                    notification.show();
                }
            }

            function UpdatedPhraseText(data) {
                var tabStrip = $find("<%=AlertTabStrip.ClientID%>");
                let selectedItem
                let selectedBox
                var generalListBox = $find("<%=GeneralListBox.ClientID%>");
                var personalListBox = $find("<%=PersonalListBox.ClientID%>");
                var personalListBoxItem = personalListBox.get_selectedItem();
                let tabCount = tabStrip.get_tabs().get_count();
                if (data) {
                    if (tabCount == 2 && generalListBox && generalListBox.get_selectedItem()) {

                        selectedItem = generalListBox.get_selectedItem();
                        selectedBox = generalListBox;
                    }
                    else if (personalListBoxItem) {
                        selectedBox = personalListBox;
                        selectedItem = personalListBoxItem;
                    }
                    selectedItem.set_text(data)

                    editPhrase(selectedItem.get_value(), selectedItem.get_text(), selectedBox)
                }
            }


            function copyPhraseToText() {
                var tabStrip = $find("<%=AlertTabStrip.ClientID%>");
                var phraseTextBox = $find("<%= alerttextbox.ClientID%>");
                var phraseTextBoxValue = phraseTextBox.get_value();
                if (phraseTextBoxValue) {
                    phraseTextBoxValue = phraseTextBoxValue + ' '
                }
                let generalListBox = $find("<%=GeneralListBox.ClientID%>");
                let personalListBoxitems = $find("<%=PersonalListBox.ClientID%>").get_selectedItem();
                let selectedPhraseTab;
                let tabCount = tabStrip.get_tabs().get_count();
                if (personalListBoxitems) {
                    selectedPhraseTab = personalListBoxitems;
                }
                else if (tabCount == 2 && generalListBox && generalListBox.get_selectedItem()) {
                    selectedPhraseTab = generalListBox.get_selectedItem();
                }
                if (selectedPhraseTab) {
                    phraseTextBox.set_value(phraseTextBoxValue + selectedPhraseTab.get_text());
                } else {
                    var notification = $find("<%=RadNotification1.ClientID%>");
                    notification.set_text("Please select a Phrase")
                    notification.show();
                }
            }


            function copyToLibraryClicked() {
                let procedureTypeId = 0;
                let selectedProcedure = $find("<%= ProcedureList.ClientID %>").get_selectedNode();
                if (selectedProcedure) {
                    procedureTypeId = $('#<%= SelectedNodeValueHiddenField.ClientID %>').val();
                    if (selectedProcedure.get_allNodes().length > 0) {
                        procedureTypeId = 0;
                    }
                }
                else if ('<%= reqOption %>' != "SystemSettings") {
                    procedureTypeId = '<%= procType %>';
                }
                if (procedureTypeId > 0) {

                    let phraseCategory = $("#<%= opsHidden.ClientID%>").val();
                    if (phraseCategory != '') {
                        var newPhraseText = $find("<%= alerttextbox.ClientID%>").get_value().trim();
                        if (newPhraseText != null && newPhraseText != '') {
                            var tabStrip = $find("<%=AlertTabStrip.ClientID%>");
                            let tabCount = tabStrip.get_tabs().get_count();
                            let selectedTab;
                            let userName;
                            if (tabCount == 2 && tabStrip.get_tabs().getTab(0).get_selected()) {
                                selectedTab = $find("<%=GeneralListBox.ClientID%>");
                                userName = ''
                            }
                            else {
                                selectedTab = $find("<%=PersonalListBox.ClientID%>");
                                userName = '<%= Session("UserID")%>';
                            }
                            var item = new Telerik.Web.UI.RadListBoxItem();
                            var obj = {};
                            obj.userName = userName;
                            obj.Category = $("#<%= opsHidden.ClientID%>").val();
                            obj.Phrase = newPhraseText;
                            obj.OperatingHospitalId = $find("<%=OperatingHospitalsRadComboBox.ClientID%>").get_value();
                            obj.ProcedureTypeId = procedureTypeId
                            $.ajax({
                                type: "POST",
                                url: "WordLibrary.aspx/AddTextToLibrary",
                                data: JSON.stringify(obj),
                                contentType: "application/json; charset=utf-8",
                                /*//dataType: "json",*/
                                success: function (r) {
                                    if (r.d != null) {
                                        item.set_text(newPhraseText);
                                        item.set_value(r.d);
                                        selectedTab.trackChanges();
                                        selectedTab.get_items().add(item);
                                        selectedTab.commitChanges()
                                    }
                                },
                                error: function (jqXHR, textStatus, data) {
                                    var notification = $find("<%=RadNotification1.ClientID%>");
                                    notification.set_text(jqXHR.responseJSON.Message);
                                    notification.show();
                                }
                            });

                        }
                        else {
                            var notification = $find("<%=RadNotification1.ClientID%>");
                            notification.set_text("Please entry a Phrase text")
                            notification.show();
                        }
                    }
                    else {
                        var notification = $find("<%=RadNotification1.ClientID%>");
                        notification.set_text("Please select a Phrase category");
                        notification.show();
                    }


                }
                else {
                    var notification = $find("<%=RadNotification1.ClientID%>");
                    notification.set_text("Please select a Procedure");
                    notification.show();
                }
            }

            function deletePhrase(PhraseID, po) {
                var obj = {};
                obj.PhraseID = PhraseID;
                obj.OperatingHospitalId = $find("<%=OperatingHospitalsRadComboBox.ClientID%>").get_value();
                $.ajax({
                    type: "POST",
                    url: "WordLibrary.aspx/DeleteTextFromLibrary",
                    data: JSON.stringify(obj),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (r) {
                        po.trackChanges();
                        po.deleteItem(po.get_selectedItem());
                        po.commitChanges();
                    },
                    error: function (jqXHR, textStatus, data) {
                        var notification = $find("<%=RadNotification1.ClientID%>");
                        notification.set_text(jqXHR.responseJSON.Message)
                        notification.show();
                    }
                });
            }

            function editPhrase(PhraseID, Phrase, po) {
                var obj = {};
                obj.PhraseID = PhraseID;
                obj.Phrase = Phrase;
                obj.OperatingHospitalId = $find("<%=OperatingHospitalsRadComboBox.ClientID%>").get_value();

                $.ajax({
                    type: "POST",
                    url: "WordLibrary.aspx/EditTextFromLibrary",
                    data: JSON.stringify(obj),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (r) {
                        var item = po.get_selectedItem();
                        po.trackChanges();
                        item.set_text(Phrase);
                        po.commitChanges();
                    },
                    error: function (jqXHR, textStatus, data) {
                        var notification = $find("<%=RadNotification1.ClientID%>");


                        notification.set_text(jqXHR.responseJSON.Message);
                        notification.show();
                    }
                });
            }


            function PhraseCategoryClicked(radioId) {
                $('#<%= opsHidden.ClientID %>').val(radioId);
            }

            function searchOnEnter(event) {
                if (event.keyCode === 13 || event.which === 13) {
                    event.preventDefault();
                    $('#<%= searchButton.ClientID %>').click();
                }
            }
            function noneRadioChecked() {
                $("#PhraseCategoryDropDown").val("");
            }

            function showImage(event) {
                event.stopPropagation();
                $('#<%=invisibleButton.ClientID%>').click();
            }

            function GetRadWindow() {
                var oWindow = null;
                if (window.radWindow) oWindow = window.radWindow;
                else if (window.frameElement.radWindow) oWindow = window.frameElement.radWindow;
                return oWindow;
            }

            function Close() {
                GetRadWindow().close();
            }

            function updateANDclose(data) {
                var hv = $("#<%= opsHidden.ClientID%>").val();
                if (hv != null) {
                    switch (hv) {
                        case 'CommentRep':
                        case 'FriendlyRep':
                            GetRadWindow().BrowserWindow.CalledAdviceCommentsFn(data, hv);
                            break;
                        case 'FollowUp':
                            GetRadWindow().BrowserWindow.CalledFollowUpFn(data, hv);
                            break;
                        case 'FurtherProc':
                            GetRadWindow().BrowserWindow.CalledFurtherProceduresFn(data, hv);
                            break;
                        case 'PathFollowUp':
                        case 'PathCommentRep':
                        case 'PathFurtherProc':
                            GetRadWindow().BrowserWindow.CalledPathFn(data, hv);
                            break;
                        default:
                            GetRadWindow().BrowserWindow.CalledFn(data, hv);
                            break;
                    }
                }
                Close();
            }

        </script>
    </telerik:RadScriptBlock>

    <style type="text/css">
        .RadListBox .rlbItem,
        .RadListBox .rlbItem.rlbSelected {
            border: 0;
            border-bottom: 1px solid #f2f2f2;
        }

        .upButton .rbText {
            text-align: right !important;
            margin-top: -3px;
        }

        .upButton .rbPrimaryIcon, .downButton .rbPrimaryIcon, .searchButton .rbPrimaryIcon {
            top: 8px !important;
        }

        .downButton .rbText {
            text-align: right !important;
            margin-top: -3px;
        }

        .labelText {
            font-size: 12px;
            font-family: "Segoe UI",Arial,Helvetica,sans-serif;
            color: black;
        }

        .img-buttons {
            background: none !important;
            padding: 0 !important;
            margin: 8px 2px;
            border: none !important;
        }

        .display {
            display: block !important;
        }

        .manButton {
            border-radius: 10px !important;
            font-weight: bold !important;
            color: seagreen !important;
        }


        .ProcedureColumn {
            width: 20% !important
        }

        .RadPrompt .rpInput {
            height: 40px !important; /* Adjust the height value as needed */
        }

        .rtsTxt {
            font-size: 14px
        }

        .rtsLink {
            padding: 6px !important;
        }

        .RadTreeView .rtImg {
            width: 12px !important
        }

        .procedureIcon {
            width: 15px !important;
            margin-left: 10px;
            vertical-align: bottom;
            display: none;
        }

        .rfdSelect {
            width: 480px !important;
        }

        .rfdSelectBox_Metro li {
            padding: 2px 5px !important
        }

        .categoryName {
            color: black;
            font-size: 12px;
            font-family: "Segoe UI", Arial, Helvetica, sans-serif;
        }

        .phraseIcon {
            width: 25px
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" EnablePageMethods="true" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" Skin="Metro" Position="Center" Width="400" Height="150" BorderStyle="Ridge" BorderColor="Red" AutoCloseDelay="0" ShowCloseButton="true" TitleIcon="none" ContentIcon="Warning" EnableShadow="true" EnableRoundedCorners="true" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <telerik:RadButton ID="invisibleButton" runat="server" AutoPostBack="true" Style="display: none;" OnClick="Get_AllData">
                </telerik:RadButton>
                <div class="optionsHeading" id="divTitle" runat="server">Phrase Library </div>
                <div id="HospitalFilterDiv" runat="server" class="optionsBodyText" style="margin: 10px;">
                    Operating Hospital:&nbsp;<telerik:RadComboBox ID="OperatingHospitalsRadComboBox" CssClass="filterDDL" runat="server" Width="270px" AutoPostBack="true" OnSelectedIndexChanged="Get_AllData" OnClientSelectedIndexChanged="noneRadioChecked" />
                </div>
                <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />
                <telerik:RadFormDecorator ID="UserMaintenanceRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
                <asp:ObjectDataSource ID="GeneralAlertDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetPhrasesData">
                    <SelectParameters>
                        <asp:Parameter Name="UserID" DefaultValue="" Type="String" />
                        <asp:ControlParameter Name="PhraseCategory" ControlID="opsHidden" PropertyName="Value" Type="String" ConvertEmptyStringToNull="true" />
                        <asp:ControlParameter Name="OperatingHospitalId" ControlID="OperatingHospitalsRadComboBox" PropertyName="SelectedValue" Type="Int32" />
                        <asp:ControlParameter Name="ProcedureTypeIds" ControlID="SelectedNodeValueHiddenField" PropertyName="Value" Type="String" />
                        <asp:ControlParameter Name="PhraseText" ControlID="PhraseSearchHiddenField" PropertyName="Value" Type="String" ConvertEmptyStringToNull="true" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                <asp:ObjectDataSource ID="PersonalAlertDataSource" runat="server" TypeName="UnisoftERS.DataAccess" SelectMethod="GetPhrasesData">
                    <SelectParameters>
                        <asp:ControlParameter Name="PhraseCategory" ControlID="opsHidden" PropertyName="Value" Type="String" ConvertEmptyStringToNull="true" />
                        <asp:SessionParameter SessionField="UserID" Name="UserID" Type="String"></asp:SessionParameter>
                        <asp:ControlParameter Name="OperatingHospitalId" ControlID="OperatingHospitalsRadComboBox" PropertyName="SelectedValue" Type="Int32" />
                        <asp:ControlParameter Name="ProcedureTypeIds" ControlID="SelectedNodeValueHiddenField" PropertyName="Value" Type="String" />
                        <asp:ControlParameter Name="PhraseText" ControlID="PhraseSearchHiddenField" PropertyName="Value" Type="String" ConvertEmptyStringToNull="true" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                <div id="FormDiv" runat="server" class=" " style="margin-left: 10px; margin-top: 30px">
                    <asp:HiddenField runat="server" ID="opsHidden" />

                    <table id="table2" runat="server" style="width: 500px !important; margin-right: 20px; border: 1px solid #d9d9d9;">

                        <tr>
                            <td id="procedureColumn" runat="server" style="border-right: 1px solid #d9d9d9; display: none; width: 70px !important; vertical-align: top;" rowspan="6">
                                <asp:HiddenField ID="SelectedNodeValueHiddenField" runat="server" />
                                <asp:HiddenField ID="SelectedParentNodeValueHiddenField" runat="server" />
                                <telerik:RadTreeView ID="ProcedureList" runat="server" Width=" 250px" OnClientNodeClicking="noneRadioChecked" />
                            </td>
                            <td style="padding-left: 30px;">
                                <div style="display: flex; justify-content: space-between;">
                                    <telerik:RadTabStrip ID="AlertTabStrip" runat="server" Style="padding-bottom: 10px;" Orientation="HorizontalTop" MultiPageID="AlertMultipage" SelectedIndex="0" ReorderTabsOnSelect="true" Skin="Metro" RenderMode="Lightweight" OnTabClick="AlertTabStrip_TabClick" OnClientTabSelecting="noneRadioChecked">
                                        <Tabs>
                                            <telerik:RadTab runat="server" Text="General library" ID="GeneralTab" PageViewID="GeneralPageView" />
                                            <telerik:RadTab runat="server" Text="Personal library" ID="PersonalTab" PageViewID="PersonalPageView" />
                                        </Tabs>
                                    </telerik:RadTabStrip>
                                    <asp:HiddenField runat="server" ID="PhraseSearchHiddenField" />
                                    <div style="display: flex;">
                                        <telerik:RadTextBox ID="PhraseSearchBox" runat="server" MinLength="3" MaxLength="500" Skin="Windows7" Height="35px" Width="200px" placeholder="Search here" onkeydown="searchOnEnter(event)" />
                                        <telerik:RadButton ID="searchButton" runat="server" AutoPostBack="true" Width="10" Height="35" Icon-PrimaryIconUrl="~/Images/magnifying-glass-solid.svg" Skin="Windows7" ButtonType="SkinnedButton" CssClass="searchButton" OnClick="PhraseSearchBox_TextChanged">
                                        </telerik:RadButton>
                                    </div>

                                </div>

                            </td>
                        </tr>
                        <tr>
                            <td id="PhraseCategory" runat="server" style="display: none; padding-left: 30px; padding-bottom: 7px;">
                                <div style="display: flex; justify-content: space-between ; width:100%!important ">
                                    <span class=" categoryName">Phrase Category  </span>
                                    <telerik:RadComboBox ID="PhraseCategoryDropDown" runat="server" Style="width: 485px; padding: 0 !important" AutoPostBack="true" OnSelectedIndexChanged="DropDownList_SelectedIndexChanged">
                                        <Items>
                                            <telerik:RadComboBoxItem Text="Please select a category" Value="" />
                                            <telerik:RadComboBoxItem Text="NPSA Alert" Value="NPSAAlert" />
                                            <telerik:RadComboBoxItem Text="Cancer Screening" Value="CancerScreening" />
                                            <telerik:RadComboBoxItem Text="Follow up" Value="FollowUp" />
                                            <telerik:RadComboBoxItem Text="Further procedure(s)" Value="FurtherProc" />
                                            <telerik:RadComboBoxItem Text="Advice/comments (are printed at the end of the report)" Value="CommentRep" />
                                            <telerik:RadComboBoxItem Text="Pathology Further procedure(s)" Value="PathFurtherProc" />
                                            <telerik:RadComboBoxItem Text="Pathology Advice/comments (are printed at the end of the report)" Value="PathCommentRep" />
                                            <telerik:RadComboBoxItem Text="Pathology Follow up" Value="PathFollowUp" />
                                            <telerik:RadComboBoxItem Text="Advice/comments for patient friendly report" Value="FriendlyRep" />
                                        </Items>
                                    </telerik:RadComboBox>

                                </div>

                            </td>
                            <td></td>
                        </tr>
                        <tr>
                            <td id="tdTabStrip" runat="server" style="padding-left: 30px">
                                <telerik:RadMultiPage ID="AlertMultipage" runat="server" SelectedIndex="0">
                                    <telerik:RadPageView ID="GeneralPageView" runat="server" Height="200px">
                                        <telerik:RadListBox ID="GeneralListBox" runat="server" Height="200px" Width="600px" DataSourceID="GeneralAlertDataSource" DataTextField="Phrase" DataValueField="PhraseID">
                                            <ButtonSettings TransferButtons="All"></ButtonSettings>
                                        </telerik:RadListBox>
                                    </telerik:RadPageView>
                                    <telerik:RadPageView ID="PersonalPageView" runat="server" Height="200px">
                                        <telerik:RadListBox ID="PersonalListBox" runat="server" Height="200px" Width="600px" DataSourceID="PersonalAlertDataSource" DataTextField="Phrase" DataValueField="PhraseID" />
                                    </telerik:RadPageView>
                                </telerik:RadMultiPage>
                            </td>
                            <td>
                                <telerik:RadButton ID="EditRadLinkButton" runat="server" AutoPostBack="true" Text="test" Skin="Windows7" ButtonType="SkinnedButton" CssClass="img-buttons" OnClick="Window_open">
                                    <ContentTemplate>
                                        <img id="editing" width="25px" height="25px" class="phraseIcon" src="../../Images/phrase_edit.png" alt="" title="Edit" />
                                    </ContentTemplate>
                                </telerik:RadButton>
                                <br />
                                <telerik:RadLinkButton ID="DeleteRadLinkButton" runat="server" CssClass="img-buttons" OnClientClicked="phraseDelete">
                                    <ContentTemplate>
                                        <img id="deleteing" width="25px" height="25px" class="phraseIcon" src="../../Images/phrase_delete.png" alt="" title="Delete" />
                                    </ContentTemplate>
                                </telerik:RadLinkButton>
                            </td>
                        </tr>
                        <tr>
                            <td runat="server" id="tdArrows" style="padding-left: 120px; padding-top: 10px; padding-bottom: 10px;">
                                <telerik:RadButton ID="CopyToBoxButton" runat="server" Text="Copy phrase to text" AutoPostBack="false" Icon-PrimaryIconUrl="~/Images/arrow-down-solid.svg" Width="150" Height="30" Skin="Windows7" ButtonType="SkinnedButton" CssClass=" upButton manButton" OnClientClicked="copyPhraseToText">
                                </telerik:RadButton>
                                <span style="padding-right: 20px"></span>
                                <telerik:RadButton ID="CopyToLibraryButton" runat="server" Text="Add entire text to library" AutoPostBack="false" Icon-PrimaryIconUrl="~/Images/arrow-up-solid.svg" Width="180" Height="30" Skin="Windows7" ButtonType="SkinnedButton" CssClass=" downButton manButton" OnClientClicked="copyToLibraryClicked">
                                </telerik:RadButton>
                            </td>
                            <td></td>
                        </tr>
                        <tr>
                            <td style="padding-left: 30px">
                                <asp:Label ID="lblAlert" runat="server" Text="" Font-Bold="true" CssClass="labelText" Width="400" />
                                <telerik:RadTextBox ID="alerttextbox" runat="server" TextMode="MultiLine" Height="110px" Width="600px" AutoPostBack="false" Wrap="true"></telerik:RadTextBox>
                            </td>
                            <td></td>
                        </tr>
                        <tr>
                            <td style="padding-top: 15px;">
                                <div id="buttonsdivwindow4" style="margin-bottom: 10px">
                                    <telerik:RadButton ID="SaveAlertButton" runat="server" Text="Update & Close" Skin="Web20" AutoPostBack="true" CssClass="  manButton" OnClick="saveNPSAalert" Icon-PrimaryIconCssClass="telerikSaveButton Buttonicon" />
                                    <telerik:RadButton ID="CloseAlertButton" runat="server" Text="Cancel" AutoPostBack="false" Skin="Web20" CssClass="  manButton" OnClientClicked="Close" Icon-PrimaryIconCssClass="telerikCancelButton Buttonicon" />
                                </div>
                            </td>
                            <td></td>
                        </tr>
                    </table>
                </div>
            </ContentTemplate>

        </asp:UpdatePanel>
        <telerik:RadWindowManager ID="RadWindowManager1" runat="server" ShowContentDuringLoad="false" Style="z-index: 7001" Skin="Metro" EnableShadow="True" Modal="True" Behaviors="Close, Move" ReloadOnShow="True" VisibleStatusbar="false">
            <Windows>
            </Windows>
        </telerik:RadWindowManager>

    </form>




</body>
</html>
