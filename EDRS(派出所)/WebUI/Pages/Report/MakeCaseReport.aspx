﻿<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MakeCaseReport.aspx.cs"
    Inherits="WebUI.MakeCaseReport" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>卷宗制作工作量统计</title>
    <link href="/LigerUI/lib/ligerUI/skins/Aqua/css/ligerui-all.css" rel="stylesheet"
        type="text/css" />
    <link href="/LigerUI/lib/LigerUI/skins/ligerui-icons.css" rel="stylesheet" type="text/css" />
    <script src="/Scripts/tools/easyui/jquery.min.js" type="text/javascript"></script>
    <script src="/Scripts/tools/easyui/src/json2.js" type="text/javascript"></script>
    <%--<script src="/LigerUI/lib/ligerUI/js/core/base.js" type="text/javascript"></script>--%>
    <script src="/LigerUI/lib/LigerUI/js/ligerui.all.js" type="text/javascript"></script>
    <script src="/Scripts/unit.juris.tree.js" type="text/javascript"></script>
    <style type="text/css">
        /*右边框背景颜色*/
        body
        {
            background: #eef2f5;
            }
         .l-panel-bwarp {
            background: white;
        }
        
        .l-panel-topbar
        {
            padding: 5px 0;
            border-bottom: 1px solid #ccc;
            display: inline-block;
            width: 100%;
             background: white;
        }
        .l-text-wrapper
        {
            display: inline-block;
        }
        .l-text-field
        {
            position: inherit;
        }
        .l-panel-header
        {
            display: none;
        }
        .l-text-combobox
        {
            height: 21px;
        }
        .l-box-select-inner
        {
            max-height: 300px;
            min-height: 300px;
        }
        .l-box-select-inner .l-tree
        {
            min-width: 400px !important;
        }
        .l-tree-icon
        {
            background: url('/images/icons/3.png') no-repeat !important;
            background-position: center center !important;
        }
        /* 按钮 */
        div .l-button {
            color: white;
            top: -4px;
        }
        div#btn_search {
            background: #ed6d4a;
        }
        div#btn_deriveExcel {
            background: #92afb7;
        }
        
        /*左右边框*/
      div .l-layout-left,div .l-layout-right{
         border: 1px solid #dde0e3;
         border-top: 4px solid #129bbc;
         border-radius: 10px;
    }
    
       div#searchbar {
            padding: 10px;
            margin-bottom: 5px;
            overflow-x: auto;
            border: 1px solid #ccc;
            border-top: 4px solid #129bbc;
            border-radius: 10px;
            background: white;
        }
        .l-panel { 
            overflow: hidden;
            border: none;
            border-top: 0;
            border-radius: 0;
}
    </style>
</head>
<body style="padding:15px;">
    <div id="searchbar" style="padding-bottom: 5px; line-height: 28px; padding: 5px;">
        <table>
            <tr>
                <td>
                    &nbsp;&nbsp;单位名称：
                </td>
                <td>
                    <input id="txt_dwbm" type="text" name="txt_dwbm" />
                </td>
                <td>
                    &nbsp;&nbsp;创建时间：
                </td>
                <td>
                    <input id="txt_time_begin" type="text" name="txt_time_begin" ligerui="width: 100" />
                </td>
                <td>
                    &nbsp;&nbsp;-&nbsp;&nbsp;
                </td>
                <td>
                    <input id="txt_time_end" type="text" name="txt_time_end" ligerui="width: 100" />
                </td>
                <td>
                    &nbsp;&nbsp;制作人：
                </td>
                <td>
                    <input id="txt_dutyman" class="l-text" type="text" name="txt_dutyman" ligerui="width: 100" />
                </td>
                <td>
                    &nbsp;&nbsp;
                    <input type="radio" value="businessType" name="showType" checked="checked" />按业务类型
                    <input type="radio" value="AJLXType" name="showType" />按<%= ((VersionName)0).ToString() %>类型
                </td>
                <td>
                    &nbsp;&nbsp;<div id="btn_search">
                    </div>
                    <div id="btn_deriveExcel" style="margin-left: 10px; display: inline-block; vertical-align: bottom;">
                    </div>
                </td>
            </tr>
        </table>
    </div>
    <div id="layoutMain">
        <div position="left" id="mainGrid" title="统计列表">
        </div>
        <div position="right" title="分类统计详细" id="graph">
            <div id="detailGrid">
            </div>
            <!-- 为ECharts准备一个具备大小（宽高）的Dom -->
        </div>
    </div>
    <script type="text/javascript">
        var myChart = null;
        var grid = null;
        var dwbm_tree;
        var vn = '<%= ((VersionName)0).ToString() %>';
        $(function () {
            var tree_node;
            var menu = $.ligerMenu({ top: 100, left: 100, width: 120, items:
            [
            { text: '全选/反选', click: function itemclick() {
                var sNode = tree_node;
                if (sNode == null) {
                    $.messager.alert('提示', '未选择任何节点，操作失败！', 'error');
                    return;
                }

                $(".l-expandable-close", sNode.target).click();
                if ($(".l-checkbox-checked", sNode.target).length == 0) {//未选中
                    $(".l-checkbox", sNode).removeClass("l-checkbox-checked").addClass("l-checkbox-unchecked");
                    $(".l-checkbox-unchecked", sNode.target).click();
                }
                else {
                    $(".l-checkbox", sNode).removeClass("l-checkbox-unchecked").addClass("l-checkbox-checked");
                    $(".l-checkbox-checked", sNode.target).click();
                }
            }
            }
            ]
            });

            //单位编码
            dwbm_tree = $("#txt_dwbm").unitJuris({ width: 130, checkbox: true });


            $('#btn_search').ligerButton({
                text: '查询',
                icon: '../../images/cx.png'
            });
            $('#btn_deriveExcel').ligerButton({
                width: 80,
                text: '导出Excel',
                icon: '../../images/dcExcel.png'
            });
            /*******************调整容器大小*******************/
            var layout = $("#layoutMain").ligerLayout({
                leftWidth: '49%', rightWidth: '50%', space: 2,
                allowLeftResize: false, allowRightResize: false,
                onEndResize: function () { $(window).resize(); }
            });
            $(".l-layout-header-toggle", layout.left).click(function (f) {
                console.log(layout.right);
                $(".l-layout-right").width(layout.width - (29 + layout.options.space));
                var hid = $(".l-layout-right").is(":hidden");
                if (hid == true) {
                    layout.setRightCollapse(false);
                }
                layout.setLeftCollapse(true);
                $(window).resize();
                myChart.resize();
            });
            $(".l-layout-header-toggle", layout.right).click(function () {
                $(".l-layout-left").width(layout.width - (29 + layout.options.space));
                var hid = $(".l-layout-left").is(":hidden");
                if (hid == true) {
                    layout.setLeftCollapse(false);
                }
                layout.setRightCollapse(true);
                $(window).resize();
                myChart.resize();
            });
            layout.leftCollapse.toggle.click(function () {
                var hid = $(".l-layout-right").is(":hidden");
                if (hid == false) {
                    $(".l-layout-left").width('50%');
                    $(".l-layout-right").width('50%');
                }
                layout.setLeftCollapse(false);
                $(window).resize();
                myChart.resize();
            });
            layout.rightCollapse.toggle.click(function () {
                var hid = $(".l-layout-left").is(":hidden");
                if (hid == false) {
                    $(".l-layout-left").width('50%');
                    $(".l-layout-right").width('50%');
                }
                layout.setRightCollapse(false);
                $(window).resize();
                //$("#graph").ligerPanel({ width: 668, height: 530 });
                myChart.resize();
            });
            var betime = '<%=SetBeTime %>';
            $("#txt_time_begin").ligerDateEditor({ labelWidth: 80, labelAlign: 'center', initValue: betime + '-12-26', onChangeDate: function (value) {
                var d1 = new Date(value.replace(/\-/g, "\/"));
                var d2 = new Date($("#txt_time_end").val().replace(/\-/g, "\/"));
                if (d1 >= d2) {
                    $("#txt_time_end").val("");
                }
            }
            });
            $("#txt_time_end").ligerDateEditor({ labelWidth: 80, labelAlign: 'center', onChangeDate: function (value) {
                var d1 = new Date($("#txt_time_begin").val().replace(/\-/g, "\/"));
                var d2 = new Date(value.replace(/\-/g, "\/"));
                if (d1 > d2) {
                    $("#txt_time_end").val("");
                    $.ligerDialog.warn('制作开始日期不能大于结束日期');
                }
            }
            });




            $("#btn_search").click(function () {
                if (grid) {
                    grid.loadServerData({
                        action: "GetMakeCaseReport",
                        b_date: $("#txt_time_begin").val(),
                        e_date: $("#txt_time_end").val(),
                        username: $("#txt_dutyman").val(),
                        unit: dwbm_tree.getValue(),
                        page: 1, pagesize: grid.options.pageSize
                    });
                }
                else {
                    SearchData();
                }
            });

            //导出
            $("#btn_deriveExcel").click(function () {
                $.ligerDialog.waitting('正在导出,请稍候...');
                $.ajax({
                    type: "POST",
                    url: "/Pages/Report/MakeCaseReport.aspx",
                    data: {
                        t: "DeriveData",
                        b_date: $("#txt_time_begin").val(),
                        e_date: $("#txt_time_end").val(),
                        username: $("#txt_dutyman").val(),
                        unit: dwbm_tree.getValue(),
                        page: grid.options.page, pagesize: grid.options.pageSize
                    },
                    dataType: 'json',
                    timeout: 10000,
                    cache: false,
                    beforeSend: function () {
                    },
                    error: function (xhr) {
                        $.ligerDialog.closeWaitting();
                        $.ligerDialog.error('网络连接错误');
                        return false;
                    },
                    success: function (data) {
                        if (data.t == "win") {
                            location.href = "/download.aspx?t=getmodel&fileid=" + data.v;
                        } else {
                            $.ligerDialog.error(data.v);
                        }
                        $.ligerDialog.closeWaitting();
                    }
                });
            });
        });
        var datailGrid;
        function SearchData() {
            grid = $("#mainGrid").ligerGrid({
                columns: [
                { display: '单位名称', name: 'cbdw_mc', width: 150 },
                { display: '制作人员', name: 'jzscrxm', width: 100 },
                { display: vn + '数量', name: 'ajcount', width: 100, totalSummary: { type: 'sum'} },
                { display: '卷数', name: 'jcount', width: 100, totalSummary: { type: 'sum'} },
                { display: '文件数', name: 'wcount', width: 100, totalSummary: { type: 'sum'} },
                { display: '文件页数', name: 'pagecount', width: 100, totalSummary: { type: 'sum'} },
                // { display: '单位编码', name: 'cbdw_bm', width: 10, hide: true }
                ], pageSize: 20,
                title: '卷宗制作工作量', showTitle: true,
                pageSizeOptions: [10, 20, 50, 100, 500],
                enabledSort: true, rownumbers: true,
                usePager: true, width: '100%', height: '100%', heightDiff: 20,
                url: '/Handler/ZZJG/DZJZ_Report.ashx',
                parms: {
                    action: "GetMakeCaseReport",
                    b_date: $("#txt_time_begin").val(),
                    e_date: $("#txt_time_end").val(),
                    username: $("#txt_dutyman").val(),
                    unit: dwbm_tree.getValue()
                },
                onSelectRow: function (rowdata, rowid, rowobj) {
                    InitDetailGrid(rowdata);
                    return false;
                }
            });

            $("input:radio").click(function () {
                var rowdata = grid.getSelectedRow();
                if (rowdata)
                    InitDetailGrid(rowdata);
            });
            if (!datailGrid) {
                datailGrid = $("#detailGrid").ligerGrid({
                    columns: [
                { display: '业务类型', name: 'cbdw_mc', width: 150 },
                { display: vn + '数量', name: 'ajcount', width: 100, totalSummary: { type: 'sum'} },
                { display: '卷数', name: 'jcount', width: 100, totalSummary: { type: 'sum'} },
                { display: '文件数', name: 'wcount', width: 100, totalSummary: { type: 'sum'} },
                { display: '文件页数', name: 'pagecount', width: 100, totalSummary: { type: 'sum'} }
                ],
                    title: '按业务',
                    pageSizeOptions: [10, 20, 50, 100, 500], pageSize: 50,
                    enabledSort: true, rownumbers: true,
                    usePager: true, width: '100%', height: '100%', heightDiff: 20,
                    url: '/Handler/ZZJG/DZJZ_Report.ashx'
                });
            }
        }
        function InitDetailGrid(rowdata) {
            $.ligerDialog.waitting('正在查询详细信息,请稍候...');
            var _column;
            var _title;
            var _type;
            $("input:radio").each(function () {
                if (this.checked) {
                    if ($(this).val() == "businessType") {
                        _type = 'businessType';
                        _title = '按业务统计';
                        _column = { display: '业务名称', name: 'ywmc', width: 150 };
                    }
                    else {
                        _type = 'groupByType';
                        _title = '按' + vn + '类别统计';
                        _column = { display: vn + '类别', name: 'ajlbmc', width: 200 };
                    }
                }
            });
            datailGrid = $("#detailGrid").ligerGrid({
                columns: [
                _column,
                { display: vn + '数量', name: 'ajcount', width: 100, totalSummary: { type: 'sum'} },
                { display: '卷数', name: 'jcount', width: 100, totalSummary: { type: 'sum'} },
                { display: '文件数', name: 'wcount', width: 100, totalSummary: { type: 'sum'} },
                { display: '文件页数', name: 'pagecount', width: 100, totalSummary: { type: 'sum'} }
                ],
                title: _title,
                pageSizeOptions: [10, 20, 50, 100, 500], pageSize: 50,
                enabledSort: true, rownumbers: true,
                usePager: true, width: '100%', height: '100%', heightDiff: 20,
                url: '/Handler/ZZJG/DZJZ_Report.ashx',
                parms: {
                    action: "GetMakeCaseReportDetail",
                    username: rowdata.jzscrxm,
                    txt_unit: rowdata.cbdw_bm,
                    b_date: $("#txt_time_begin").val(),
                    e_date: $("#txt_time_end").val(),
                    groupType: _type
                },
                onSuccess: function (data, grid) {
                    setTimeout(function () { $.ligerDialog.closeWaitting(); }, 200);
                }
            });
        }
    </script>
</body>
<script src="/LigerUI/lib/LigerUI/JScript1.js" type="text/javascript"></script>
</html>
