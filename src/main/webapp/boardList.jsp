<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="vo.*" %>
<%
	int currentPage = 1;
	if(request.getParameter("currentPage")!=null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	
	int rowPerPage = 3;
	if(request.getParameter("rowPerPage") != null) {
		rowPerPage = Integer.parseInt(request.getParameter("rowPerPage"));
	}
	int beginRow = (currentPage - 1) * rowPerPage;

	/* 
		// 1:1 관계 -> INNER JOIN, FK가 두 테이블에 동일
		SELECT b.board_title boardTitle, f.origin_filename originFilename, f.save_filename saveFilename, f.path
		FROM board b INNER JOIN board_file f
		ON b.board_no = f.board_no
		ORDER BY b.createdate DESC
	*/
	
	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileupload", "root", "java1234");
	String listSql = "SELECT b.board_no boardNo, b.board_title boardTitle, b.member_id memberId, b.createdate createdate, b.updatedate updatedate,"
			+ " f.board_file_no boardFileNo, f.origin_filename originFilename, f.save_filename saveFilename, f.path"
			+ " FROM board b INNER JOIN board_file f ON b.board_no = f.board_no ORDER BY b.createdate DESC LIMIT ?,?";
	PreparedStatement listStmt = conn.prepareStatement(listSql);
	listStmt.setInt(1, beginRow);
	listStmt.setInt(2, rowPerPage);
	ResultSet listRs = listStmt.executeQuery();
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(listRs.next()) {
		HashMap<String, Object> m = new HashMap<>();
		m.put("boardNo", listRs.getInt("boardNo"));
		m.put("boardTitle", listRs.getString("boardTitle"));
		m.put("memberId", listRs.getString("memberId"));
		m.put("boardFileNo", listRs.getString("boardFileNo"));
		m.put("originFilename", listRs.getString("originFilename"));
		m.put("saveFilename", listRs.getString("saveFilename"));
		m.put("path", listRs.getString("path"));
		m.put("updatedate", listRs.getString("updatedate"));
		m.put("createdate", listRs.getString("createdate"));
		list.add(m);
	}
	
	String totalRowSql = "select count(*) from board";
	PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
	ResultSet totalRowRs = totalRowStmt.executeQuery();
	
	int totalRow = 0;
	if(totalRowRs.next()){
		totalRow = totalRowRs.getInt("count(*)");
	}
	
	int pagePerPage = 10;
	int lastPage = totalRow / rowPerPage;
	if(totalRow%rowPerPage != 0){
		lastPage = lastPage + 1;
	}
	int minPage = (((currentPage - 1) / pagePerPage) * pagePerPage) + 1;
	int maxPage = minPage + (pagePerPage - 1);
	if(maxPage > lastPage){
		maxPage = lastPage;
	}
%>   
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<a href="<%=request.getContextPath()%>/login.jsp">로그인</a>
	<a href="<%=request.getContextPath()%>/logoutAction.jsp">로그아웃</a>
	<h1>PDF 자료 목록</h1>
	<table border="1">
		<tr>
			<td>boardTitle</td>
			<td>originFilename</td>
			<td>memberId</td>
			<td>updatedate</td>
			<td>createdate</td>
			<td>수정</td>
			<td>삭제</td>
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
				<td><%=(String)m.get("memberId")%></td>
				<td><%=(String)m.get("updatedate")%></td>
				<td><%=(String)m.get("createdate")%></td>
				<td><a href="<%=request.getContextPath()%>/modifyBoard.jsp?boardNo=<%=m.get("boardNo")%>&boardFileNo=<%=m.get("boardFileNo")%>">수정</a></td>
				<td><a href="<%=request.getContextPath()%>/removeBoard.jsp?boardNo=<%=m.get("boardNo")%>&boardFileNo=<%=m.get("boardFileNo")%>">삭제</a></td>
			</tr>
		<%
			}
		%>
	</table>
		<%
			if(minPage > 1){
		%>
			<a href="<%=request.getContextPath()%>/boardList.jsp?currentPage=<%=minPage-1%>">이전</a>
		<%
			} for(int i=minPage; i<=maxPage; i=i+1){
				if(i == currentPage){
		%>
				<span><%=i%></span>&nbsp;
		<%			
				} else {
		%>
				<a href="<%=request.getContextPath()%>/boardList.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
		<%			
				}
			}
			if(maxPage != lastPage){
		%>
			<a href ="<%=request.getContextPath()%>/boardList.jsp?currentPage=<%=minPage+1%>">다음</a>
		<%		
			}
		%>	
</body>
</html>