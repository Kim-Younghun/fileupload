<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%
	/* 
		// 1:1 관계 -> INNER JOIN, FK가 두 테이블에 동일
		SELECT b.board_title boardTitle, f.origin_filename originFilename, f.save_filename saveFilename, f.path
		FROM board b INNER JOIN board_file f
		ON b.board_no = f.board_no
		ORDER BY b.createdate DESC
	*/
	
	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileupload", "root", "java1234");
	String listSql = "SELECT b.board_title boardTitle, f.origin_filename originFilename, f.save_filename saveFilename, f.path" 
			+ " FROM board b INNER JOIN board_file f ON b.board_no = f.board_no ORDER BY b.createdate DESC";
	PreparedStatement listStmt = conn.prepareStatement(listSql);
	ResultSet listRs = listStmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(listRs.next()) {
		HashMap<String, Object> m = new HashMap<>();
		m.put("boardTitle", listRs.getString("boardTitle"));
		m.put("originFilename", listRs.getString("originFilename"));
		m.put("saveFilename", listRs.getString("saveFilename"));
		m.put("path", listRs.getString("path"));
		list.add(m);
	}
%>   
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h1>PDF 자료 목록</h1>
	<table border="1">
		<tr>
			<td>boardTitle</td>
			<td>originFilename</td>
		</tr>
		<%
			for(HashMap<String, Object> m : list) {
		%>
			<tr>
				<td><%=(String)m.get("boardTitle")%></td>
				<td>
					<!-- 프로젝트명 /upload /saveFilename, 누를경우 다운로드 되도록 다운로드 경로 설정 -->
					<a href="<%=request.getContextPath()%>/<%=(String)m.get("path")%>/<%=(String)m.get("saveFilename")%>" download="<%=(String)m.get("saveFilename")%>">
					<%=(String)m.get("originFilename")%>
					</a>
				</td>
			</tr>
		<%
			}
		%>
	</table>
</body>
</html>