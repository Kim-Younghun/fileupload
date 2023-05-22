<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(request.getParameter("boardFileNo"));

	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileupload", "root", "java1234");
	String listSql = "SELECT b.board_no boardNo, b.board_title boardTitle, f.board_file_no boardFileNo, f.origin_filename originFilename" 
			+ " FROM board b INNER JOIN board_file f ON b.board_no = f.board_no Where b.board_no = ? AND board_file_no = ?";
	PreparedStatement listStmt = conn.prepareStatement(listSql);
	listStmt.setInt(1, boardNo);
	listStmt.setInt(2, boardFileNo);
	ResultSet listRs = listStmt.executeQuery();
	HashMap<String, Object> map = null;
	if(listRs.next()) {
		map = new HashMap<>();
		map.put("boardNo", listRs.getInt("boardNo"));
		map.put("boardTitle", listRs.getString("boardTitle"));
		map.put("boardFileNo", listRs.getString("boardFileNo"));
		map.put("originFilename", listRs.getString("originFilename"));
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<style type="text/css">
	table, th, td {
		border: 1px solid #FF0000;
	}
</style>
</head>
<body>
	<h1>board & boardFile 수정</h1>
	<form action="<%=request.getContextPath()%>/modifyBoardAction.jsp" method="post" enctype="multipart/form-data">
		<input type="hidden" name="boardNo" value="<%=map.get("boardNo")%>">
		<input type="hidden" name="boardFileNo" value="<%=map.get("boardFileNo")%>">
		<table>
			<tr>
				<th>boardTitle</th>
				<td>
					<textarea cols="50" rows="3" name="boardTitle" required="required"><%=map.get("boardTitle")%></textarea>
				</td>
			</tr>
			<tr>
				<!-- 공백이 넘어왔을 경우를 따져서 분기를 Action 페이지에서 수행 -->
				<th>boardFile(수정전 파일 : <%=map.get("originFilename")%>)</th>
				<td>
					<input type="file" name="boardFile" >
				</td>
			</tr>
		</table>
		<button type="sumbit">수정</button>
	</form>
</body>
</html>