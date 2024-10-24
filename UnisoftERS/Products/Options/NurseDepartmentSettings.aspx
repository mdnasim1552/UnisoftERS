<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Options_NurseDepartmentmentSettings"
    CodeBehind="NurseDepartmentSettings.aspx.vb" %>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">



<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../Scripts/Global.js"></script>
    <script type="text/javascript" src="../../Scripts/jquery-3.6.3.min.js"></script>
    <link type="text/css" href="../../Styles/Site.css" rel="stylesheet" />
    <style type="text/css">
        .button-primary 
        {
                background-color: #007bff; /* Bootstrap Primary Color */
                color: white;
                border: none;
                padding: 10px 20px;
                border-radius: 4px;
                cursor: pointer;
        }
        #AddNewQuestionRadWindow_C
        {
          overflow: hidden !important;
        }    
        .custom-notoification-title
         {
                background: #25a0da;
         }
        #QuestionAlertRadWindow_C
        {
            overflow: hidden !important;
            height: 140px !important;
            width: 350px !important;
        }
        .alert-question 
        {
            padding-left: 15px;
            padding-top: 10px;
            overflow: hidden;
            font-size: 14px;
        }
    </style>

    <telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">

        <script type="text/javascript">
            var appTimeoutValue, appTimeoutChanged;

            $(document).ready(function () {
                var radTextBoxControl = $find("<%= DropdownOptionTextBox.ClientID %>");
                     if (!radTextBoxControl) {
                         console.error("RadTextBox control not found.");
                         return;
                     }

                     var textBox = radTextBoxControl.get_element();
                     var placeholderText = "Enter options separated by commas";

                     showPlaceholder(textBox, placeholderText);

                     $(textBox).focus(function () {
                         if ($(textBox).val() === placeholderText) {
                             $(textBox).val("");
                             $(textBox).removeClass("placeholder-text");
                         }
                     });

                     $(textBox).blur(function () {
                         if ($(textBox).val().trim() === "") {
                             showPlaceholder(textBox, placeholderText);
                         }
                     });

                 });
            function showPlaceholder(textBox, placeholderText) {
                if ($(textBox).val() === placeholderText || $(textBox).val().trim() === "") {
                    $(textBox).val(placeholderText);
                    $(textBox).addClass("placeholder-text");
                }
            }

            function openAddItemWindow(itemId, itemName, sortOrder) {
                var oWnd = $find("<%= AddNewItemRadWindow.ClientID%>");
                if (itemId > 0) {
                    $find('<% =AddNewItemSaveRadButton.ClientID%>').set_text("Update");
                    oWnd.set_title('Edit Section');
                    $find("<%=AddNewItemRadTextBox.ClientID%>").set_value(itemName);
                    $find("<%=SectionOrderTextBox.ClientID%>").set_value(sortOrder);
                    document.getElementById('<%=hiddenItemId.ClientID%>').value = itemId;
                } else {
                    $find('<% =AddNewItemSaveRadButton.ClientID%>').set_text("Save");
                    oWnd.set_title('Add Section');
                    $find("<%=AddNewItemRadTextBox.ClientID%>").set_value("");
                    $find("<%=SectionOrderTextBox.ClientID%>").set_value("");
                    document.getElementById('<%=hiddenItemId.ClientID%>').value = 0;
                }
                oWnd.show();
                return false;
            }

            function openQuestionAddItemWindow(itemId, question, sectionId, optional, freeText, yesNo, dropdownOption, dropdownOptionText, sortOrder) {
                var oWnd = $find("<%= AddNewQuestionRadWindow.ClientID%>");
                var dropdown = $find("<%=SectionDropdown.ClientID%>");
                $find("<%=DropdownOptionTextBox.ClientID%>").set_value("Enter options separated by commas");
                $('.showDropdownText').hide();
                if (itemId > 0) {
                    $find('<% =AddNewQuestionSaveRadButton.ClientID%>').set_text("Update");
                              oWnd.set_title('Edit Question');

                              if (optional == "True") {
                                  optional = true;
                              }
                              else {
                                  optional = false;
                              }
                              if (freeText == "True") {
                                  freeText = true;
                              }
                              else {
                                  freeText = false;
                              }
                              if (yesNo == "True") {
                                  yesNo = true;
                              }
                              else {
                                  yesNo = false;
                              }
                              if (dropdownOption == "True") {
                                  dropdownOption = true;
                              }
                              else {
                                  dropdownOption = false;
                              }
                              var selectedItem = dropdown.findItemByValue(sectionId);
                              if (selectedItem) {
                                  selectedItem.select();
                              }

                              $find("<%=AddNewQuestionRadTextBox.ClientID%>").set_value(question);
                              $find("<%=chkOptionalRadComboBox.ClientID%>").set_checked(optional);
                              $find("<%=chkFreeTextRadComboBox.ClientID%>").set_checked(freeText);
                              $find("<%=chkYesNoRadComboBox.ClientID%>").set_checked(yesNo);
                              $find("<%=DropdownOption.ClientID%>").set_checked(dropdownOption);
                              $find("<%=questionSortOrder.ClientID%>").set_value(sortOrder);
                              oWnd.set_height(355);
                              if (dropdownOption == true) {

                                  if (dropdownOptionText !== "" && dropdownOptionText !== null) {
                                      $find("<%=DropdownOptionTextBox.ClientID%>").set_value(dropdownOptionText);
                                  }

                                  $('.showDropdownText').show();
                                  oWnd.set_height(460);
                              }

                              document.getElementById('<%=HiddenItemId1.ClientID%>').value = itemId;
                          }
                          else {

                              $find('<% =AddNewQuestionSaveRadButton.ClientID%>').set_text("Save");
                              oWnd.set_title('Add Question');
                              var items = dropdown.get_items();
                              if (items.get_count() > 0) {
                                  var firstItem = items.getItem(0);
                                  firstItem.select();
                              }
                              $find("<%=AddNewQuestionRadTextBox.ClientID%>").set_value("");
                              $find("<%=chkOptionalRadComboBox.ClientID%>").set_checked(false);
                              $find("<%=chkFreeTextRadComboBox.ClientID%>").set_checked(false);
                                $find("<%=chkYesNoRadComboBox.ClientID%>").set_checked(false);
                                $find("<%=DropdownOption.ClientID%>").set_checked(false);
                                $find("<%=questionSortOrder.ClientID%>").set_value("");
                                document.getElementById('<%=HiddenItemId1.ClientID%>').value = 0;
                                oWnd.set_height(355);
                            }

                            oWnd.show();
                            return false;
            }

            function closeAddItemWindow() {
                var oWnd = $find("<%= AddNewItemRadWindow.ClientID%>");
                if (oWnd != null)
                    oWnd.close();
                return false;
            }
            function closeAddQuestionWindow()
            {
                var oWnd = $find("<%= AddNewQuestionRadWindow.ClientID%>");
                if (oWnd != null)
                    oWnd.close();
                return false;
            }
            function refreshGrid(arg) {
                if (!arg) {
                    $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("Rebind");
                }
                else {
                    $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("RebindAndNavigate");
                }
            }
            function refreshQuestionGrid(arg)
            {
                if (!arg)
                {
                    $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("RebindQuestion");
                }
                else
                {
                    $find("<%= RadAjaxManager1.ClientID %>").ajaxRequest("RebindQuestionAndNavigate");
                }
             }
            function Show() {
                if (confirm("Are you sure you want to suppress this item?")) {
                    return true;
                }
                else {
                    return false;
                }
            }
            function ShowQuestion() {
                if (confirm("Are you sure you want to suppress this item?")) {
                    return true;
                }
                else {
                    return false;
                }
            }
            function onCheckboxChecked(sender, args) 
            {

                var checkbox = sender;
                $find("<%= DropdownOptionTextBox.ClientID %>").set_value("Enter options separated by commas");
                var radWindow = $find("<%= AddNewQuestionRadWindow.ClientID %>");
                if (checkbox.get_checked())
                {
                    
                    $('.showDropdownText').show();
                    $find("<%= chkYesNoRadComboBox.ClientID %>").set_checked(false);
                    radWindow.set_height(460);
                }
                else
                {
                    $('.showDropdownText').hide();

                    radWindow.set_height(355);
                }
            }
            function onYesNoCheckboxChecked(sender,args)
            {
                var checkbox = sender;
                $find("<%= DropdownOptionTextBox.ClientID %>").set_value("Enter options separated by commas");
                var radWindow = $find("<%= AddNewQuestionRadWindow.ClientID %>");
                if (checkbox.get_checked())
                {
                    $('.showDropdownText').hide();
                    $find("<%= DropdownOption.ClientID %>").set_checked(false);
                    radWindow.set_height(355);
                }

            }
            function validateAddNewQuestionForm(sender, args) {
                var questionTextBox = $find("<%= AddNewQuestionRadTextBox.ClientID %>");
                var dropdownOptionTextBox = $find("<%= DropdownOptionTextBox.ClientID %>");
                var optionalCheckBox = $find("<%= chkOptionalRadComboBox.ClientID %>");
                var freeTextCheckBox = $find("<%= chkFreeTextRadComboBox.ClientID %>");
                var yesNoCheckBox = $find("<%= chkYesNoRadComboBox.ClientID %>");
                var dropdownOptionCheckBox = $find("<%= DropdownOption.ClientID %>");
                var sectionDropdown = $find("<%= SectionDropdown.ClientID %>");

                var valMsg = '';

                var isValid = true;
     
                if (questionTextBox.get_value().trim() === "") {
                    valMsg +=  'Question is required.' + '<br>'
                    isValid = false;
                }
                if (sectionDropdown.get_value().trim() === "" || sectionDropdown.get_value() === "0") {
                        valMsg +=   "Section is required." + '<br>';
                    }
                if (!freeTextCheckBox.get_checked() && !yesNoCheckBox.get_checked() && !dropdownOptionCheckBox.get_checked()) {
                    valMsg +=  '(Free  Text/ Yes/No/ Dropdown option) is required.' + '<br>';
                    isValid = false; 
                }
                if ((!freeTextCheckBox.get_checked() && !yesNoCheckBox.get_checked() && !dropdownOptionCheckBox.get_checked() && isValid) || dropdownOptionCheckBox.get_checked() && (dropdownOptionTextBox.get_value().trim() === ""  || dropdownOptionTextBox.get_value().trim() === "Enter options separated by commas"))
                {
                    valMsg += 'Dropdown Option free text is required.' + '<br>';
                    isValid = false; 
                }

                if (!isValid) {

                    var questionAlertWindow = $find("<%= QuestionAlertRadWindow.ClientID %>");
                    var alertDiv = document.getElementById("alertMessageDiv");
                    alertDiv.innerHTML = '<p style="color: red;">' + valMsg + '</p>';
                    questionAlertWindow.set_width(350);
                    questionAlertWindow.set_height(170)
                    questionAlertWindow.show();

                    args.set_cancel(true);
                }
                else
                {
                    if (!dropdownOptionCheckBox.get_checked())
                    {
                        $find("<%= DropdownOptionTextBox.ClientID %>").set_value("");

                    }
                }
            }

        </script>
    </telerik:RadCodeBlock>
</head>

<body>
    <script type="text/javascript">
</script>
    <form id="form1" runat="server">
        <asp:HiddenField ID="hiddenItemId" runat="server" />
        <asp:HiddenField ID="HiddenItemId1" runat="server" />
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" DecorationZoneID="ControlsRadPane" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" />

        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest">
            <AjaxSettings>

                <telerik:AjaxSetting AjaxControlID="SaveButton">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="RadNotification1" />
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="RadAjaxManager1">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SectionRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="SectionRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="SectionRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
                <telerik:AjaxSetting AjaxControlID="QuestionRadGrid">
                    <UpdatedControls>
                        <telerik:AjaxUpdatedControl ControlID="QuestionRadGrid" LoadingPanelID="RadAjaxLoadingPanel1"></telerik:AjaxUpdatedControl>
                    </UpdatedControls>
                </telerik:AjaxSetting>
            </AjaxSettings>
        </telerik:RadAjaxManager>
        <asp:ObjectDataSource ID="SectionsObjectDataSource" runat="server" SelectMethod="GetNurseModuleSectionList" TypeName="UnisoftERS.Options"></asp:ObjectDataSource>
        <asp:ObjectDataSource ID="QuestionsObjectDataSource" runat="server" SelectMethod="GetNurseModuleQuestionList" TypeName="UnisoftERS.Options"></asp:ObjectDataSource>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="1200px" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Height="900">
            <telerik:RadPane ID="ControlsRadPane" runat="server">
                <div style="margin: 0px 10px;">
                    <div style="margin-top: 10px;"></div>
                    <telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1" ReorderTabsOnSelect="true" Skin="MetroTouch" RenderMode="Lightweight"
                        Orientation="HorizontalTop">
                        <Tabs>
                            <telerik:RadTab Text="Sections" Value="1" Font-Bold="false" Selected="true" PageViewID="RadPageView0" />
                            <telerik:RadTab Text="Questions" Value="2" Font-Bold="false" PageViewID="RadPageView1" Visible="true" />
                        </Tabs>
                    </telerik:RadTabStrip>
                    <telerik:RadMultiPage ID="RadMultiPage1" runat="server">
                        <telerik:RadPageView ID="RadPageView0" runat="server" Selected="true">
                            <div style="padding-bottom: 10px;" class="ConfigureBg">
                                <telerik:RadGrid ID="SectionRadGrid" runat="server"
                                    DataSourceID="SectionsObjectDataSource" AllowPaging="True" AllowSorting="True" Skin="Metro" Width="100%" GroupPanelPosition="Top" AutoGenerateColumns="False" PageSize="25">
                                    <HeaderStyle Font-Bold="true" Height="25" />
                                    <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="SectionId">

                                        <Columns>
                                            <telerik:GridTemplateColumn UniqueName="TemplateColumn">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="EditLinkButton" runat="server" Text="Edit" ToolTip="Edit this item" Font-Italic="true"></asp:LinkButton>
                                                    &nbsp;&nbsp;
                                                    <asp:LinkButton ID="SuppressLinkButton" runat="server" Text="Suppress" ToolTip="Suppress this item"
                                                        Enabled="true" OnClientClick="return Show()"
                                                        CommandName="SuppressItem" Font-Italic="true"></asp:LinkButton>
                                                </ItemTemplate>
                                                <HeaderTemplate>
                                                    <telerik:RadButton ID="AddNewSectionButton" runat="server" Text="Add New Section" Skin="Metro" OnClientClicked="openAddItemWindow" AutoPostBack="false" />
                                                </HeaderTemplate>
                                            </telerik:GridTemplateColumn>
                                            <telerik:GridBoundColumn UniqueName="SectionName" DataField="SectionName" HeaderText="SectionName" SortExpression="SectionName" HeaderStyle-Width="320px"></telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn UniqueName="SortOrder" DataField="SortOrder" HeaderText="SortOrder" SortExpression="SortOrder" HeaderStyle-Width="320px"></telerik:GridBoundColumn>
                                        </Columns>
                                        <NoRecordsTemplate>
                                            <div style="margin-left: 5px;">No records found</div>
                                        </NoRecordsTemplate>
                                    </MasterTableView>
                                    <ItemStyle Height="30" />
                                    <AlternatingItemStyle Height="30" />
                                    <PagerStyle Mode="NumericPages"></PagerStyle>
                                </telerik:RadGrid>
                            </div>
                        </telerik:RadPageView>
                        <telerik:RadPageView ID="RadPageView1" runat="server">
                            <div style="padding-bottom: 10px;" class="ConfigureBg">
                                <telerik:RadGrid ID="QuestionRadGrid" runat="server"
                                    DataSourceID="QuestionsObjectDataSource" AllowPaging="True" AllowSorting="True" Skin="Metro" Width="100%" GroupPanelPosition="Top" AutoGenerateColumns="False" PageSize="25">
                                    <HeaderStyle Font-Bold="true" Height="25" />
                                    <MasterTableView ShowHeadersWhenNoRecords="true" ClientDataKeyNames="QuestionId">

                                        <Columns>
                                            <telerik:GridTemplateColumn UniqueName="QuestionTemplateColumn">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="EditQLinkButton" runat="server" Text="Edit" ToolTip="Edit this item" Font-Italic="true"></asp:LinkButton>
                                                    <asp:LinkButton ID="SuppressLinkButton" runat="server" Text="Suppress" ToolTip="Suppress this item"
                                                        Enabled="true" OnClientClick="return ShowQuestion()"
                                                        CommandName="QuestionSuppressItem" Font-Italic="true"></asp:LinkButton>
                                                </ItemTemplate>
                                                <HeaderTemplate>
                                                    <telerik:RadButton ID="AddNewQuestionButton" runat="server" Text="Add New Question" Skin="Metro" OnClientClicked="openQuestionAddItemWindow" AutoPostBack="false" />
                                                </HeaderTemplate>
                                            </telerik:GridTemplateColumn>
                                            <telerik:GridBoundColumn UniqueName="SectionName" DataField="SectionName" HeaderText="Section" SortExpression="SectionName" HeaderStyle-Width="320px"></telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn UniqueName="Question" DataField="Question" HeaderText="Question" SortExpression="Question" HeaderStyle-Width="320px"></telerik:GridBoundColumn>
                                            <telerik:GridCheckBoxColumn UniqueName="YesNo" DataField="YesNo" HeaderText="Yes/No" SortExpression="YesNo" HeaderStyle-Width="320px"></telerik:GridCheckBoxColumn>
                                            <telerik:GridCheckBoxColumn UniqueName="FreeText" DataField="FreeText" HeaderText="Free Text" SortExpression="Free Text" HeaderStyle-Width="320px"></telerik:GridCheckBoxColumn>
                                            <telerik:GridCheckBoxColumn DataField="Optional" HeaderText="Mandatory" UniqueName="Optional" SortExpression="Optional" HeaderStyle-Width="320px"></telerik:GridCheckBoxColumn>
                                            <telerik:GridCheckBoxColumn UniqueName="DropdownOption" DataField="DropdownOption" HeaderText="Dropdown Option" SortExpression="DropdownOption" HeaderStyle-Width="320px"></telerik:GridCheckBoxColumn>
                                            <telerik:GridBoundColumn UniqueName="DropdownOptionText" DataField="DropdownOptionText" HeaderText="Dropdown Text" SortExpression="DropdownOptionText" HeaderStyle-Width="320px"></telerik:GridBoundColumn>
                                            <telerik:GridBoundColumn UniqueName="SortOrder" DataField="SortOrder" HeaderText="Sort Order" SortExpression="SortOrder" HeaderStyle-Width="320px"></telerik:GridBoundColumn>
                                        </Columns>
                                        <NoRecordsTemplate>
                                            <div style="margin-left: 5px;">No records found</div>
                                        </NoRecordsTemplate>
                                    </MasterTableView>
                                    <ItemStyle Height="30" />
                                    <AlternatingItemStyle Height="30" />
                                    <PagerStyle Mode="NumericPages"></PagerStyle>
                                </telerik:RadGrid>
                            </div>
                        </telerik:RadPageView>
                    </telerik:RadMultiPage>
                </div>
                <telerik:RadWindowManager ID="AddNewItemRadWindowManager" runat="server" ShowContentDuringLoad="false"
                    Style="z-index: 5001" Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true">
                    <Windows>
                        <telerik:RadWindow ID="AddNewItemRadWindow" runat="server" ReloadOnShow="true" Title="New Item"
                            KeepInScreenBounds="true" Width="370px" Height="185px" VisibleStatusbar="false" ShowContentDuringLoad="true">
                            <ContentTemplate>
                                <table cellspacing="3" cellpadding="3">

                                    <tr>
                                        <td style="width: 40%;">Section:</td>
                                        <td style="width: 60%;">
                                            <telerik:RadTextBox ID="AddNewItemRadTextBox" runat="server" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="width: 40%;">Order:</td>
                                        <td style="width: 60%;">
                                            <telerik:RadTextBox ID="SectionOrderTextBox" runat="server" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div id="buttonsdiv" style="height: 10px; padding-top: 36px; vertical-align: central;">
                                                <telerik:RadButton ID="AddNewItemSaveRadButton" CssClass="button-primary" runat="server" Text="Save" Skin="Web20" />
                                                <telerik:RadButton ID="AddNewItemCancelRadButton" runat="server" Text="Cancel" Skin="Web20" OnClientClicked="closeAddItemWindow" />
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </ContentTemplate>
                        </telerik:RadWindow>
                        <telerik:RadWindow ID="QuestionAlertRadWindow" runat="server" Modal="true" ReloadOnShow="true" KeepInScreenBounds="true" VisibleStatusbar="false" VisibleOnPageLoad="false" Title="Please Correct the following" BackColor="#ffffcc">
                                <ContentTemplate>
                                    <div id="alertMessageDiv" class="alert-question">
  
                                    </div>
                                </ContentTemplate>
                         </telerik:RadWindow>
                    </Windows>
                </telerik:RadWindowManager>

                <telerik:RadWindowManager ID="AddNewQuestionRadWindowManager" runat="server" ReloadOnShow="true" AutoClose="false" ShowContentDuringLoad="false" Style="z-index: 5000" Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true">
                    <Windows>
                        <telerik:RadWindow ID="AddNewQuestionRadWindow" runat="server" ReloadOnShow="true" Title="New Question"
                            KeepInScreenBounds="true" Width="500px" Height="355px" VisibleStatusbar="false" ShowContentDuringLoad="false">
                            <ContentTemplate>
                                <table cellspacing="3" cellpadding="3" style="width: 100%; table-layout: fixed;margin-top: 7px">
                                    <tr>
                                        <td style="width: 25%;">Question:</td>
                                        <td style="width: 65%;">
                                            <telerik:RadTextBox ID="AddNewQuestionRadTextBox" runat="server" Width="100%" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="width: 25%;">Section:</td>
                                        <td style="width: 65%;">
                                            <telerik:RadComboBox ID="SectionDropdown" DataTextField="SectionName" runat="server" DataValueField="SectionId"  />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="width: 25%;">Procedure Type:</td>
                                        <td style="width: 65%;">
                                            <telerik:RadComboBox ID="NurseModuleProcedureTypeRadComboBox" DataTextField="SectionName" runat="server" DataValueField="SectionId"  />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="width: 25%;">Sort Order:</td>
                                        <td style="width: 65%;">
                                            <telerik:RadTextBox ID="questionSortOrder" runat="server" Width="100%" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="width: 25%;">Mandatory:</td>
                                        <td style="width: 65%;">
                                            <telerik:RadCheckBox ID="chkOptionalRadComboBox" runat="server" AutoPostBack="false" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="width: 25%;">Free Text:</td>
                                        <td style="width: 65%;">
                                            <telerik:RadCheckBox ID="chkFreeTextRadComboBox" runat="server" AutoPostBack="false" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="width: 25%;">Yes/No:</td>
                                        <td style="width: 75%;">
                                            <telerik:RadCheckBox ID="chkYesNoRadComboBox" runat="server" AutoPostBack="false" OnClientClicked="onYesNoCheckboxChecked"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="width: 25%;">Dropdown Option:</td>
                                        <td style="width: 75%;">
                                            <telerik:RadCheckBox ID="DropdownOption" runat="server" AutoPostBack="false" OnClientClicked="onCheckboxChecked" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div class="showDropdownText">
                                                <telerik:RadTextBox ID="DropdownOptionTextBox" class="placeholder-text" runat="server" TextMode="MultiLine" Width="470" Height="105" />
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div id="buttonsdiv1" style="height: 10px; padding-top: 26px; width: 200px;">
                                                <telerik:RadButton CssClass="button-primary" ID="AddNewQuestionSaveRadButton" runat="server" Text="Save" Skin="Web20" OnClientClicking="validateAddNewQuestionForm" />
                                                <telerik:RadButton ID="AddNewQuestionCancelRadButton" runat="server" Text="Cancel" Skin="Web20" OnClientClicked="closeAddQuestionWindow" />
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </ContentTemplate>
                        </telerik:RadWindow>
                    </Windows>
                </telerik:RadWindowManager>


            </telerik:RadPane>

        </telerik:RadSplitter>
    </form>
</body>
</html>

