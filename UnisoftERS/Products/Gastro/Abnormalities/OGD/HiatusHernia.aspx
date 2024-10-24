<%@ Page Language="VB" AutoEventWireup="false" Inherits="UnisoftERS.Products_Gastro_Abnormalities_OGD_HiatusHernia" Codebehind="HiatusHernia.aspx.vb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <telerik:RadStyleSheetManager ID="RadStyleSheetManager1" runat="server" />
    <script type="text/javascript" src="../../../../Scripts/jquery-3.6.3.min.js"></script>
    <script type="text/javascript" src="../../../../Scripts/global.js"></script>
    <link type="text/css" href="../../../../Styles/Site.css" rel="stylesheet" />

  <script type="text/javascript">
      var hiatusHerniaValueChanged = false;
      $(window).on('load', function () {
          $('input[type="checkbox"]').each(function () {
              ToggleTRs($(this));
              
          });
      });

      $(document).ready(function () {
          $("#PostSurgeryTable tr td:first-child input:checkbox, input[type=text]").change(function () {
              ToggleTRs($(this));
              hiatusHerniaValueChanged = true;
          });

          $("#NoneCheckBox").change(function () {
              ToggleNoneCheckBox($(this).is(':checked'));
              hiatusHerniaValueChanged = true;
          });
          //for this page issue 4166  by Mostafiz
          $(window).on('beforeunload', function () {
              if (hiatusHerniaValueChanged) {
                  valueChange();
                  $("#SaveButton").click();
              }
          });
          $(window).on('unload', function () {
              localStorage.clear();
          });
      });

      function valueChange() {
          
          var noneChecked = $("#FormDiv input:checkbox:checked").length;
          if (noneChecked) {
              localStorage.setItem('valueChanged', 'true');
          } else {
              localStorage.setItem('valueChanged', 'false');
          }
      }


      function CloseWindow() {
          window.parent.CloseWindow();
      }
       //changed by mostafiz issue 3647 also solve for redundantly showing data
      function ToggleTRs(chkbox) {
          if (chkbox[0].id != "NoneCheckBox") {
              var checked = chkbox.is(':checked');
              if (checked) {
                  $("#NoneCheckBox").prop('checked', false);
              }
              chkbox.closest('td')
                  .nextUntil('tr').each(function () {
                      if (checked) {
                          var txt = chkbox.siblings('label').html();
                          chkbox.siblings('label').html(txt + ' of length :');
                          $(this).show();
                      }
                      else {
                          var txt = chkbox.siblings('label').html();
                          txt = txt.replace(" of length :", "");
                          chkbox.siblings('label').html(txt);
                          $(this).hide();
                          ClearControls($(this));
                      }
                  });
              var subRows = chkbox.closest('td').closest('tr').attr('hasChildRows');
              if (typeof subRows !== typeof undefined && subRows == "1") {
                  chkbox.closest('tr').nextUntil('tr [headRow="1"]').each(function () {
                      if (checked) {
                          $(this).show();
                      }
                      else {
                          $(this).hide();
                          ClearControls($(this));
                      }
                  });
              }
          }
      }

     
        //changed by mostafiz issue 3647 also solve for redundantly showing data
      function ToggleNoneCheckBox(checked) {
          if (checked) {
              $("#PostSurgeryTable tr td:first-child").each(function () {   
                  $(this).find("input:checkbox:checked").prop('checked', false);
                  $(this).find("input:checkbox").trigger('change');
              });
          }
      }

      //changed by mostafiz issue 3647 also solve for redundantly showing data
      function ClearControls(tableCell) {
          tableCell.find("input:radio:checked").prop('checked', false);
          tableCell.find("input:checkbox:checked").prop('checked', false);
          tableCell.find("input:text").val("");
      }
  </script>
</head>
<body>
    <telerik:RadScriptBlock runat="server">
        <script type="text/javascript">
            function savePage() {
                $find('<%= RadAjaxManager1.ClientID %>').ajaxRequest();
            }            

        </script>
    </telerik:RadScriptBlock>  
    <form id="form1" runat="server">
        <telerik:RadScriptManager ID="PostSurgeryRadScriptManager" runat="server" />
        <telerik:RadFormDecorator ID="PostSurgeryRadFormDecorator" runat="server" DecoratedControls="All" DecorationZoneID="FormDiv" Skin="Web20" />
        <telerik:RadNotification ID="RadNotification1" runat="server" VisibleOnPageLoad="false" />
        <telerik:RadAjaxManager ID="RadAjaxManager1" runat="server" OnAjaxRequest="RadAjaxManager1_AjaxRequest" />
        
        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
        <div class="abnorHeader">Hiatus Hernia</div>
        <telerik:RadSplitter ID="MainPageRadSplitter" runat="server" Width="100%" Orientation="Horizontal" BorderSize="0" PanesBorderSize="0" Skin="Windows7">
            <telerik:RadPane ID="ControlsRadPane" runat="server" Scrolling="Y" Width="95%" Height="410">



                <div id="FormDiv">
                    <div class="siteDetailsContentDiv">
                        <div class="rgview" id="rgAbnormalities" runat="server">


                            <table id="PostSurgeryTable" class="rgview" cellpadding="0" cellspacing="0" width="780px">
                                <colgroup>
                                    <col><col><col>
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th width="350px" class="rgHeader" style="text-align: left;">
                                            <asp:CheckBox ID="NoneCheckBox" runat="server" Text="None" />
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td style="padding:0px 0px 0px 6px;">
                                            <table style="width:100%; ">
                                                <tr headRow="1" hasChildRows="1">
                                                    <td style="border:none;width:170px;" >
                                                        <asp:CheckBox ID="SlidingCheckBox" runat="server" Text="Sliding" />
                                                    </td>
                                                    <td childRow="1" style="border:none;">
                                                        <span>
                                                            <telerik:RadNumericTextBox ID="SlidingLengthTextBox" runat="server"
                                                                ShowSpinButtons="true"
                                                                IncrementSettings-InterceptMouseWheel="true"
                                                                IncrementSettings-Step="1"
                                                                Width="50px"
                                                                MinValue="0">
                                                               
                                                                <NumberFormat DecimalDigits="1" />
                                                            </telerik:RadNumericTextBox>
                                                            <span style="margin-left: -5px;">cm</span>
                                                        </span>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td style="padding:0px 0px 0px 6px;">
                                            <table style="width:100%; ">
                                                <tr headRow="1">
                                                    <td style="border:none;width:170px;" >
                                                        <asp:CheckBox ID="ParaoesophagealCheckBox" runat="server" Text="Paraoesophageal" />
                                                    </td>
                                                    <td childRow="1" style="border:none;">
                                                        <span>
                                                            <telerik:RadNumericTextBox ID="ParaLengthTextBox" runat="server"
                                                                ShowSpinButtons="true"
                                                                IncrementSettings-InterceptMouseWheel="true"
                                                                IncrementSettings-Step="1"
                                                                Width="50px"
                                                                MinValue="0">
                                                               
                                                                <NumberFormat DecimalDigits="1" />
                                                            </telerik:RadNumericTextBox>
                                                            <span style="margin-left: -5px;">cm</span>
                                                        </span>
                                                    </td>
                                                </tr>
                                            </table>
                                        </td>
                                    </tr>

                                </tbody>
                            </table>

                        </div>
                    </div>
                </div>




            </telerik:RadPane>
            <telerik:RadPane ID="ButtonsRadPane" runat="server" Scrolling="None" Height="33px" CssClass="SiteDetailsButtonsPane">
                <div id="cmdOtherData" style="height: 10px; display:none; margin-left: 10px; padding-top: 6px;">
                    <telerik:RadButton ID="SaveButton" runat="server" Text="Save" Skin="Web20" Icon-PrimaryIconCssClass="telerikSaveButton"/>
                    <telerik:RadButton ID="CancelButton" runat="server" Text="Close" Skin="Web20" OnClientClicking="CloseWindow" Icon-PrimaryIconCssClass="telerikCancelButton"/>
                </div>
            </telerik:RadPane>
        </telerik:RadSplitter>
         </ContentTemplate>
        </asp:UpdatePanel>

    </form>
</body>
</html>
