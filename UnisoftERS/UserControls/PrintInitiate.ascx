<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="PrintInitiate.ascx.vb" Inherits="UnisoftERS.PrintInitiate" %>

<telerik:RadCodeBlock ID="RadCodeBlock1" runat="server">
    <script type="text/javascript">

        $(window).on('Load',function () {
            $('#<%=ReturnToRadioButtonList.ClientID%>').on('change', function () {
                var returnTo = $("#<%=ReturnToRadioButtonList.ClientID%> input:checked").val();
                if (returnTo == "3") { //if start a new procedure is selected
                    $('#<%=DeleteImagesVideosCheckbox.ClientID%>').prop('checked', false);
                }
            });
            TogglePrintButton();
            TogglePatientCopiedDetails();
            toggleCopyToRefCon();
            toggleCopyToOther();
            togglePrintGPEmailAddress();
        });
        
        $(window).on('beforeunload', function () {
            //DeleteGeneratedPdfFile();
        });
         function itemClicked(list, args) {
	        if (args.get_item().get_value() === "3") {
		        $find("<%=cbxProcedure.ClientID%>").enable();
	        }
	        else {
		        $find("<%=cbxProcedure.ClientID%>").disable();
	        }
        }

        function TogglePrintButton() {
            var gpReportbox = $("#<%= GPReportCountDiv.ClientID%>");
            var gpPhotos = $("#<%= PhotosCountDiv.ClientID%>");
            var gpLab= $("#<%= LabRequestCountDiv.ClientID%>");
            var gpPatient = $("#<%= PatientCopyCountDiv.ClientID%>");
            var gpPrintPhotos = $("#<%= PrintPhotosOnGPReportDiv.ClientID%>");
            if ($("#<%= PrintGPReportCheckBox.ClientID%>").is(":checked") == true) {
                gpReportbox.show();
                gpPrintPhotos.show();
            }
            else {
                gpReportbox.hide();
                gpPrintPhotos.hide();
            }
            if ($("#<%= PrintPhotosCheckBox.ClientID%>").is(":checked") == true) {
                gpPhotos.show();
            }
            else {
                gpPhotos.hide();
            }
            if ($("#<%= PrintPatientCopyCheckBox.ClientID%>").is(":checked") == true) {
                gpPatient.show();
            }
            else {
                gpPatient.hide();
            }
            if ($("#<%= PrintLabRequestCheckBox.ClientID%>").is(":checked") == true) {
                gpLab.show();
            }
            else {
                gpLab.hide();
            }
            
            

            var btn = $find("<%= PrintButton.ClientID%>");
            var btnPrev = $find("<%= PrintPreviewButton.ClientID%>");
            if ($("#<%= PrintGPReportCheckBox.ClientID%>").is(":checked") == true
                || $("#<%= PrintPhotosCheckBox.ClientID%>").is(":checked") == true
                || $("#<%= PrintPatientCopyCheckBox.ClientID%>").is(":checked") == true
                || $("#<%= PrintLabRequestCheckBox.ClientID%>").is(":checked") == true) {
                btn.set_enabled(true);
                //btnPrev.set_enabled(true);
            }
            if ($("#<%= PrintGPReportCheckBox.ClientID%>").is(":checked") == false
                && $("#<%= PrintPhotosCheckBox.ClientID%>").is(":checked") == false
                && $("#<%= PrintPatientCopyCheckBox.ClientID%>").is(":checked") == false
                && $("#<%= PrintLabRequestCheckBox.ClientID%>").is(":checked") == false) {
                btn.set_enabled(false);
                //btnPrev.set_enabled(false);
            }
        }

        function highlightListControl(elementRef) {
            var inputElementArray = elementRef.getElementsByTagName('input');

            for (var i = 0; i < inputElementArray.length; i++) {
                var inputElementRef = inputElementArray[i];
                var parentElement = inputElementRef.parentNode;

                if (parentElement) {
                    if (inputElementRef.checked == true) {
                        $(parentElement).addClass('rdChecked');
                    }
                    else {
                        $(parentElement).removeClass('rdChecked');

                    }
                }
            }
        }

        function OpenPrintConfigureWindow() {
            var oWnd = $find("<%= PrintConfigureWindow.ClientID%>");
            var url = "<%= ResolveUrl("~/Products/Common/PrintOptions.aspx") %>";

            //oWnd.SetSize(950, 600);
            oWnd._navigateUrl = url
            oWnd.show();
            return false;
        }

        function showContentForIE(wnd) {
            if ($telerik.isIE)
                wnd.view.onUrlChanged();
        }

        function CloseVerifier() {
            window.location.replace($find("<%=PrintRadNotification.ClientID%>").get_value());
        }

        var documentUrl = document.URL;

        function GetDiagramScript() {
            var jsondata =
            {
                procedureIdFromJS: procId,
                episodeNoFromJS: epiNo,
                procedureTypeIdFromJS: procTypeId,
                colonType: cType,
                diagramNumberFromJS: diagramNum
            };

            $.ajax({
                type: "POST",
                url: documentUrl.slice(0, documentUrl.indexOf("/Products/")) + "/Products/Common/PrintReport.aspx/GenerateDiagram",
                data: JSON.stringify(jsondata),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: GetDiagramScriptSuccess,
                error: function (jqXHR, textStatus, data) {
                    //var vars = jqXHR.responseText.split("&"); 
                    //alert(vars[0]); 
                    alert("Unknown error occured while generating report. Please contact HD Clinical helpdesk.");
                }
            });
        }

        function GetDiagramScriptSuccess(responseText) {
            $("#mydiagramDiv").html(responseText.d);

            $("#mydiagramDiv").find("script").each(function (i) {
                var svgXml = eval($(this).text());

                if (svgXml == undefined) {
                    svgXml = "No diagram";
                }
                canvg('myCanvas', svgXml, { renderCallback: GetImgDataUri, ignoreMouse: true, ignoreAnimation: true });
            });
        }

        function GetImgDataUri() {
           
            var diaguri = document.getElementById('myCanvas').toDataURL("image/png");
             
            var jsondata =
            {
                base64String: diaguri
            };
            
            $.ajax({
                type: "POST",
                url: documentUrl.slice(0, documentUrl.indexOf("/Products/")) + "/Products/Common/PrintReport.aspx/SaveImgBase64",
                data: JSON.stringify(jsondata),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (result) {
                    OpenPrintWindow(cnn);
                },
                error: function (jqXHR, textStatus, data) {
                    var vars = jqXHR.responseText.split("&");
                    alert(vars[0])
                    //alert("Unknown error occured while generating report. Please contact HD Clinical helpdesk.");
                }
            });
        }

        function OpenPrintWindow(cnn) {
            var url = "<%= ResolveUrl("~/Products/Common/PrintReport.aspx") %>";

            if (cnn) {
                url = url + "?CNN=" + cnn;
                window.location.href = url;
            }
            else {
                var oWnd = $find("<%= PrintWindow.ClientID %>");

                url = url + "?PrintGPReport={1}";
                url = url + "&PrintPhotosReport={2}";
                url = url + "&PrintPatientCopyReport={3}";
                url = url + "&PrintLabRequestReport={4}";
                url = url + "&Resected={5}";
                url = url + "&ReturnToPage={6}";
                url = url + "&PreviewOnly={7}";
                url = url + "&DeleteMedia={8}";
                url = url + "&GPCopies={9}";
                url = url + "&PhotosCopies={10}";
                url = url + "&PatientCopies={11}";
                url = url + "&LabCopies={12}";
                url = url + "&PhotosOnGP={13}";
                url = url + "&PhotoSize={14}";
                url = url + "&Endo1Sig={15}";
                url = url + "&Endo2Sig={16}";
                url = url + "&PrintDoubleSided={17}";

                url = url.replace("{1}", $("#<%=PrintGPReportCheckBox.ClientID%>").is(':checked'));
                url = url.replace("{2}", $("#<%=PrintPhotosCheckBox.ClientID%>").is(':checked'));
                url = url.replace("{3}", $("#<%=PrintPatientCopyCheckBox.ClientID%>").is(':checked'));
                url = url.replace("{4}", $("#<%=PrintLabRequestCheckBox.ClientID%>").is(':checked'));
                url = url.replace("{5}", getResectionTexts());
                url = url.replace("{6}", $find("<%=ReturnToRadioButtonList.ClientID%>").get_selectedIndex());
                url = url.replace("{7}", previewOnly);
                url = url.replace("{8}", deleteMedia);
                url = url.replace("{9}", $("#<%= GPReportCount.ClientID%>").val());
                url = url.replace("{10}", $("#<%= PhotosCount.ClientID%>").val());
                url = url.replace("{11}", $("#<%= PatientCopyCount.ClientID%>").val());
                url = url.replace("{12}", $("#<%= LabRequestCount.ClientID%>").val());
                url = url.replace("{13}", $("#<%=PrintPhotosOnGPReport.ClientID%>").is(':checked'));

                url = url.replace("{14}", $("#<%=PhotoSizeRadioButtonList.ClientID %> input[type=radio]:checked").val());
                url = url.replace("{15}", $("#<%=chkEndo1Sign.ClientID %>").is(':checked'));
                url = url.replace("{16}", $("#<%=chkEndo2Sign.ClientID %>").is(':checked'));
                url = url.replace("{17}", $("#<%= PrintDoubleSidedCheckBox.ClientID %>").is(':checked'));
                //oWnd.SetSize(850, 900);
                oWnd._navigateUrl = url;
                oWnd.show();                
                //oWnd.moveTo(283, 0);
                var viewportWidth = $(window).width();
                var windowWidth = oWnd.get_width();
                var leftPosition = (viewportWidth - windowWidth) / 2;

                // Set the top position to 0 and the calculated left position to center horizontally
                oWnd.moveTo(leftPosition, 0);
            oWnd.add_close(OnClientClosePrintHandler);

                return false;
            }
        }

        function OnClientClosePrintHandler(sender, args) {
            var returnTo = $find("<%=ReturnToRadioButtonList.ClientID%>").get_selectedIndex();
	        if (returnTo != 1) {
		        var url;
                if (returnTo == 0) {
			        //clear patient session details
			        $.ajax(
				        {
					        type: "POST",
                            url: "<%= ResolveUrl("~/Products/Default.aspx")%>" + "/ClearPatientSession",
					        dataType: "json",
					        contentType: "application/json; charset=utf-8"
				        });
                    url = "<%= ResolveUrl("~/Products/Default.aspx")%>";
                    deleteCookie('patientId');

		        } else if (returnTo == 2) {
			        url = "<%= ResolveUrl("~/Products/PreProcedure.aspx")%>";
                } 
		        window.location.href = url;
            }
            
            TogglePatientCopiedDetails();
            //DeleteGeneratedPdfFile();
        }
        function DeleteGeneratedPdfFile() {
            $.ajax(
                {
                    type: "POST",
                    url: documentUrl.slice(0, documentUrl.indexOf("/Products/")) + "/Products/Common/PrintReport.aspx/DeleteGeneratedPdfFile",
                    data: JSON.stringify({}),
                    contentType: "application/json; charset = utf - 8",
                    dataType: "json"
                });
        }
        function deleteCookie(name) {
            document.cookie = name + '=; expires=Thu, 01 Jan 2024 00:00:00 UTC; path=/;';
        }

  




        function TogglePatientCopiedDetails() {
            if ($("#<%= CopyToPatientRadioButton.ClientID%>").is(':checked')) {
                $("#<%= CopyToPatientTextBox.ClientID%>").show();

                $("#<%= PatientNotCopiedReasonTextBox.ClientID%>").hide();
               <%-- $('#<%= PatientNotCopiedReasonTextBox.ClientID%>').val("");--%>
            }
            else if ($("#<%= PatientNotCopiedRadioButton.ClientID%>").is(':checked')) {
                $("#<%= PatientNotCopiedReasonTextBox.ClientID%>").show();

                $("#<%= CopyToPatientTextBox.ClientID%>").hide();
                <%--$('#<%= CopyToPatientTextBox.ClientID%>').val("");--%>
            } else {
                $("#<%= PatientNotCopiedReasonTextBox.ClientID%>").hide();
                $("#<%= CopyToPatientTextBox.ClientID%>").hide();
            }
        }

        function toggleCopyToRefCon() {
            if ($("#<%= CopyToRefConCheckBox.ClientID%>").is(":checked") == true) {
                $("#<%= CopyToRefConTD.ClientID%>").show();
            }
            else {
                var combo = $find("<%= CopyToRefConTextBox.ClientID%>");
                //if (combo != null) {
                //    combo.clearSelection();
                //}
                $("#<%= CopyToRefConTD.ClientID%>").hide();
            }
        }

        function toggleCopyToOther() {
            if ($("#<%= CopyToOtherCheckBox.ClientID%>").is(":checked") == true) {
               $("#<%= CopyToOtherTD.ClientID%>").show();
            }
            else {
                $("#<%= CopyToOtherTextBox.ClientID%>").val('');
                $("#<%= CopyToOtherTD.ClientID%>").hide();
            }
        }

        function togglePrintGPEmailAddress() {
            if ($("#<%= CopyToGPEmailAddressCheckBox.ClientID%>").is(":checked") == true) {
                $("#<%= CopyToGPEmailAddressAddManuallyTD.ClientID%>").show();
            }
            else {
                $("#<%= CopyToGPEmailAddressAddManuallyTextBox.ClientID%>").val('');
                $("#<%= CopyToGPEmailAddressAddManuallyTD.ClientID%>").hide();
            }
        }

        function setupCopyTo() {
            TogglePatientCopiedDetails();
            toggleCopyToRefCon();
            toggleCopyToOther();
            togglePrintGPEmailAddress();
        }
        
    </script>
</telerik:RadCodeBlock>
<%--<telerik:RadAjaxManagerProxy ID="AjaxManagerProxy1" runat="server">
    <AjaxSettings>
        <telerik:AjaxSetting AjaxControlID="PrintButton">
            <UpdatedControls>
                <telerik:AjaxUpdatedControl ControlID="PrintButton" UpdatePanelRenderMode="Inline" />
            </UpdatedControls>
        </telerik:AjaxSetting>
    </AjaxSettings>
</telerik:RadAjaxManagerProxy>--%>
<telerik:RadAjaxLoadingPanel ID="RadAjaxLoadingPanel1" runat="server" Skin="Metro" Modal="true">
</telerik:RadAjaxLoadingPanel>
<telerik:RadWindowManager ID="RadWindowManager1" runat="server" ShowContentDuringLoad="false"
    Style="z-index: 7001" Behaviors="Close, Move" Skin="Metro" EnableShadow="true" Modal="true">
    <Windows>
        <telerik:RadWindow ID="PrintWindow" runat="server" Title="Print report"
            Width="860px" Height="900px" ReloadOnShow="true" ShowContentDuringLoad="false"
            Modal="true" VisibleStatusbar="false" Skin="Metro" OnClientShow="showContentForIE" Behaviors="Close">
        </telerik:RadWindow>
        <telerik:RadWindow ID="PrintConfigureWindow" runat="server" Title="Configure Print Reports"
            Width="950px" Height="700px" ReloadOnShow="true" ShowContentDuringLoad="false"
            Modal="true" VisibleStatusbar="false" Skin="Metro" Behaviors="Close">
        </telerik:RadWindow>
    </Windows>
</telerik:RadWindowManager>
<telerik:RadNotification ID="RadNotification1" runat="server" Skin="Metro" Position="Center" Width="850px" Height="900px" />

<telerik:RadNotification ID="NEDValNotification" runat="server" Animation="Fade" EnableRoundedCorners="true" EnableShadow="true" Title="Please correct the following"
    LoadContentOn="PageLoad" TitleIcon="delete" Position="Center"
    AutoCloseDelay="7000" Skin="Metro" />
<telerik:RadNotification ID="PrintRadNotification" runat="server" Animation="Fade"
    EnableRoundedCorners="true" EnableShadow="true" Title="Please correct the following"
    LoadContentOn="PageLoad" TitleIcon="delete" Position="Center" OnClientHiding="OnClientHiding"
    AutoCloseDelay="7000" Skin="Web20" Width="500px" ShowCloseButton="false">
    <ContentTemplate>
        <div id="valDiv" runat="server" class="aspxValidationSummary"></div>
        <div style="height: 20px; margin-left: 10px; margin-bottom: 5px; float: right">
            <telerik:RadButton ID="CloseButtn" runat="server" Text="Close" Skin="Web20" AutoPostBack="false" OnClientClicked="CloseVerifier" />
        </div>
    </ContentTemplate>
</telerik:RadNotification>

<div style="display: none" id="mydiagramDiv"></div>
<canvas id="myCanvas" style="display: none;"></canvas>

<telerik:RadTabStrip ID="RadTabStrip1" runat="server" MultiPageID="RadMultiPage1" SelectedIndex="0" ReorderTabsOnSelect="true" Skin="Metro" Orientation="HorizontalTop" RenderMode="Lightweight">
    <Tabs>
        <telerik:RadTab Text="Print Report" />
        <telerik:RadTab Text="Copy to" />
    </Tabs>
</telerik:RadTabStrip>

<telerik:RadMultiPage ID="RadMultiPage1" runat="server" SelectedIndex="0">
    <telerik:RadPageView ID="pagePrintReport" runat="server">
        <div id="divInitiatePrint" runat="server" style="overflow: hidden; height: 470px; width: 760px; border: 1px solid #D0D0D0;" class="ReportBg">
            <fieldset id="ReportSelectFieldset" style="margin-left: 20px; margin-top: 20px; width: 73%;" runat="server">
                <legend>Select report</legend>
                <table cellspacing="10px">
                    <tbody>
                        <tr>

                            <td style="width: 40%;">
                                <table>
                                <tr>
                                    <td>
                                        Copies
                                    </td>
                                    <td />
                                </tr>
                                <tr>
                                    <td>
                                        <div id="GPReportCountDiv" runat="server"> <telerik:RadNumericTextBox runat="server" ID="GPReportCount" Width="25" Skin="Windows7" MinValue="1" MaxValue="9" NumberFormat-DecimalDigits="0" /></div>
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="PrintGPReportCheckBox" runat="server" Skin="Web20" Text="Report" OnClick="JavaScript:TogglePrintButton();" AutoPostBack="false" Enabled="true" Checked="true" />
                                    </td>
                                </tr>
                                <tr>
                                    <td />
                                    <td>
                                        <div id="PrintPhotosOnGPReportDiv" runat="server">&nbsp;&nbsp;&nbsp;&nbsp;<asp:CheckBox ID="PrintPhotosOnGPReport" runat="server" Skin="Web20" Text="Media on Report" AutoPostBack="false" Enabled="true" Checked="true" /></div>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div id="PhotosCountDiv" runat="server"><telerik:RadNumericTextBox runat="server" ID="PhotosCount" Width="25" Skin="Windows7" MinValue="0" MaxValue="9" NumberFormat-DecimalDigits="0" /></div>
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="PrintPhotosCheckBox" runat="server" Text="Media" Skin="Web20" OnClick="JavaScript:TogglePrintButton();" AutoPostBack="false" /><br />
                                    </td>
                                </tr>
                                <tr>
                                    <td />
                                    <td><table><tr><td>&nbsp;&nbsp;&nbsp;&nbsp;</td><td>
                                        <asp:RadioButtonList ID="PhotoSizeRadioButtonList" runat="server" CellSpacing="25" RepeatDirection="Vertical" RepeatLayout="Flow">
                                            <asp:ListItem Value="1" Text="Small"></asp:ListItem>
                                            <asp:ListItem Value="2" Text="Medium"></asp:ListItem>
                                            <asp:ListItem Value="3" Text="Large"></asp:ListItem>
                                        </asp:RadioButtonList>
                                        </td></tr></table>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div id="PatientCopyCountDiv" runat="server"><telerik:RadNumericTextBox runat="server" ID="PatientCopyCount" Width="25" Skin="Windows7" MinValue="0" MaxValue="9" NumberFormat-DecimalDigits="0" /></div>
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="PrintPatientCopyCheckBox" runat="server" Text="Patient Friendly Report" Skin="Web20" OnClick="JavaScript:TogglePrintButton();" AutoPostBack="false" SkinID="Windows7" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <div id="LabRequestCountDiv" runat="server"><telerik:RadNumericTextBox runat="server" ID="LabRequestCount" Width="25" Skin="Windows7" MinValue="0" MaxValue="9" NumberFormat-DecimalDigits="0" /></div>
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="PrintLabRequestCheckBox" runat="server" Text="Lab Request Form(s)" Skin="Web20" OnClick="JavaScript:TogglePrintButton();" AutoPostBack="false" />
                                    </td>
                                </tr>
                                </table>

                            </td>
                            <td style="vertical-align: top;">
                                <table style="width: 100%;">
                                    <tr>
                                        <td style="text-align: right; padding-right: 5px;">
                                            <%--<telerik:RadButton ID="CloseButton" runat="server" Text="Save & Close" Skin="Web20" Width="100px" OnClick="CloseButton_Click" />
                                            <span style="padding-left: 5px;"></span>--%>
                                            <telerik:RadButton ID="ConfigureButton" runat="server" Text="Configure" Skin="Web20" Width="80px" OnClientClicked="OpenPrintConfigureWindow" AutoPostBack="false" />
                                            <span style="padding-left: 10px;"></span>
                                            <telerik:RadButton ID="PrintPreviewButton" runat="server" Text="Preview" Skin="Web20" Width="100px" />
                                        </td>
                                    </tr>
                                </table>

                                <fieldset id="Fieldset1" runat="server">
                                    <legend style="color: red;"><span style="color: gray;">After printing, return to...</span></legend>
                                    <table cellspacing="10px">
                                        <tr>
                                            <td>
                                                <telerik:RadRadioButtonList ID="ReturnToRadioButtonList" runat="server" AutoPostBack="false" onclick="highlightListControl(this);" SkinID="Web20">
                                                    <ClientEvents OnItemClicked="itemClicked" />
                                                    <Items>
                                                        <telerik:ButtonListItem Text="the Home screen" Value="1" Selected="True" />
                                                        <telerik:ButtonListItem Text="the current page" Value="2" />
                                                        <telerik:ButtonListItem Text="add a procedure for this patient" Value="3" />
                                                    </Items>
                                                </telerik:RadRadioButtonList>
                                                <telerik:RadComboBox ID="cbxProcedure" Enabled="false" runat="server" Width="300" AllowCustomText="false" Skin="Windows7" />
                                                <asp:CheckBox ID="DeleteImagesVideosCheckbox" runat="server" Text="temporarily delete all unused photos/videos for this procedure" Checked="false" Visible="false" />
                                            </td>
                                        </tr>
                                    </table>
                                </fieldset>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <fieldset id="Fieldset2" runat="server">
                                    <legend style="color: red;"><span style="color: gray;">Signatory</span></legend>
                                    Endoscopist 1<asp:CheckBox ID="chkEndo1Sign" runat="server" Checked="true" /><br />
                                    Endoscopist 2<asp:CheckBox ID="chkEndo2Sign" runat="server" Checked="false" />
                                </fieldset>
                            </td>
                            <td style="text-align: right; padding-right: 5px;">
                                <asp:CheckBox ID="PrintDoubleSidedCheckBox" runat="server" Text="Print double sided" Skin="Web20" AutoPostBack="false" />
                                <telerik:RadButton ID="PrintButton" runat="server" Text="View and Send" Skin="Web20" Width="100px" />
                            </td>
                        </tr>
                    </tbody>
                </table>
            </fieldset>
        </div>
    </telerik:RadPageView>

    <telerik:RadPageView ID="RadPageView3" runat="server">
        <div id="multiPageDivTab3" class="multiPageDivTab">
            <table class="rptSummaryText10">
                <tr style="height: 25px;">
                    <td>
                        <asp:RadioButton ID="CopyToPatientRadioButton" AutoPostBack="false" runat="server" Text="Patient" GroupName="CopyPatientRadioButtonList"
                            onchange="TogglePatientCopiedDetails();" Skin="Windows7" />
                    </td>
                    <td></td>
                    <td>
                        <telerik:RadTextBox ID="CopyToPatientTextBox" AutoPostBack="false" runat="server" Skin="Windows7" TextMode="SingleLine" Width="300" />
                    </td>
                </tr>
                <tr>
                    <td style="padding-right: 7px">
                        <asp:RadioButton ID="PatientNotCopiedRadioButton" AutoPostBack="false" runat="server" Text="Patient NOT copied" GroupName="CopyPatientRadioButtonList"
                            onchange="TogglePatientCopiedDetails();" Skin="Windows7" />
                    </td>
                    <td></td>
                    <td></td>
                </tr>
                <tr>
                    <td style="text-align: right;">
                        <asp:Label ID="ReasonLabel" AutoPostBack="false" runat="server" Text="(reason):" />
                    </td>
                    <td></td>
                    <td>
                        <telerik:RadComboBox ID="PatientNotCopiedReasonTextBox" AutoPostBack="false" runat="server" Width="300" AllowCustomText="false" Skin="Windows7" />
                        <%-- <telerik:RadTextBox ID="PatientNotCopiedReasonTextBox" runat="server" Skin="Windows7" TextMode="SingleLine"
                            Width="300" />--%>
                    </td>
                </tr>
                <tr>
                    <td style="height: 10px;"></td>
                </tr>
                <tr style="height: 25px;">
                    <td>
                        <asp:CheckBox ID="CopyToRefConCheckBox" AutoPostBack="false" runat="server" Text="Referring Consultant"
                            onchange="toggleCopyToRefCon()" />
                    </td>
                    <td></td>
                    <td id="CopyToRefConTD" runat="server">
                        <%--<telerik:RadDropDownList ID="CopyToRefConTextBox1" runat="server" Width="300" Skin="Windows7"  />--%>
                        <telerik:RadComboBox ID="CopyToRefConTextBox" AutoPostBack="false" runat="server" AllowCustomText="false" Width="300" Skin="Windows7" />
                    </td>
                </tr>
                <tr style="height: 25px;">
                    <td>
                        <asp:CheckBox ID="CopyToOtherCheckBox" AutoPostBack="false" runat="server" Text="Other"
                            onchange="toggleCopyToOther()" />
                    </td>
                    <td></td>
                    <td id="CopyToOtherTD" runat="server">
                        <telerik:RadTextBox ID="CopyToOtherTextBox" AutoPostBack="false" runat="server" Skin="Windows7" TextMode="SingleLine" Width="300" />
                    </td>
                </tr>
                <tr style="height: 25px;" id="CopyToGPEmailAddressAddManuallyTR" runat="server">
                    <td>
                        <asp:CheckBox ID="CopyToGPEmailAddressCheckBox" AutoPostBack="false" runat="server" Text="GP" onchange="togglePrintGPEmailAddress()" />
                    </td>
                    <td></td>
                    <td id="CopyToGPEmailAddressAddManuallyTD" runat="server">
                        <telerik:RadTextBox ID="CopyToGPEmailAddressAddManuallyTextBox" AutoPostBack="false" runat="server" Skin="Windows7" TextMode="SingleLine" Width="300" EmptyMessage="Enter GP email address" />
                    </td>
                </tr>
                <tr>
                    <td style="height: 10px;"></td>
                </tr>
                <tr>
                    <td>
                        <div style="margin-left: 5px; visibility: hidden">
                            <asp:Label ID="SalutationLabel" runat="server" Text="Salutation:" />
                        </div>

                    </td>
                    <td align="right">
                        <asp:Label Style="visibility: hidden" ID="DearLabel" runat="server" Text="Dear:" />&nbsp;
                    </td>
                    <td>
                        <telerik:RadTextBox Style="visibility: hidden" ID="SalutationTextBox" runat="server" Skin="Windows7" TextMode="SingleLine"
                            Width="300" />
                    </td>
                </tr>
            </table>
        </div>
        <div style="height: 10px; margin-left: 10px; padding-top: 2px; padding-bottom: 2px">
            <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton" />
        </div>
    </telerik:RadPageView>

</telerik:RadMultiPage>


