const express = require("express")
const mysql = require("mysql")
const util = require("util")
const ejs = require("ejs");
const bodyParser = require("body-parser")
const app = express()

const PORT = 3000;
const DB_HOST = 'localhost';
const DB_USER = 'root';
const DB_PASSWORD = '';
const DB_NAME = 'coursework';
const DB_PORT = 3306;

var connection = mysql.createConnection({
    host: DB_HOST,
    user: DB_USER,
    password: DB_PASSWORD,
    database: DB_NAME,
    port: DB_PORT
})
connection.query = util.promisify(connection.query).bind(connection)

connection.connect((err) => {
    if (err) {
        console.error(`could not connect to database
            ${err}
        `)
        return
    }
    console.log("boom, you are connected")
})
app.set("view engine", "ejs")
app.use(express.static("public"))
app.use(bodyParser.urlencoded({ extended: false }))

app.get("/", async (req, res) => {
    const studentCount = await connection.query("SELECT COUNT(*) AS count FROM Student")
    const membersCount = await connection.query("SELECT COUNT(*) AS count FROM TEAM_MEMBERSHIP")
    const teamsCount = await connection.query("SELECT COUNT(*) AS count FROM TEAM")
    const coachCount = await connection.query("SELECT COUNT (*) AS count FROM COACH")
    res.render("index",
        {
            studentCount: studentCount[0].count,
            membersCount: membersCount[0].count,
            teamsCount: teamsCount[0].count,
            coachCount: coachCount[0].count
        })
})
app.get("/games", async (req, res) => {
    const games = await connection.query(`SELECT 
    G.Game_Date,
    G.Game_Time,
    G.Game_Location,
    T.Team_Name
    FROM Game G
    JOIN Team T ON G.Team_ID = T.Team_ID`)
    res.render("games", { games: games })
})
app.get("/teams", async (req, res) => {
    const teams = await connection.query("SELECT * FROM TEAM")
    res.render("teams", { teams: teams })
})
app.get("/students", async (req, res) => {
    const students = await connection.query(`SELECT URN,Stu_FName,Stu_LName,Stu_DOB,Stu_Phone,Crs_Title,Stu_Type
    FROM STUDENT,COURSE
    WHERE STUDENT.Stu_Course = COURSE.Crs_Code`)
    res.render("students", { students: students })
})

app.get("/team_memberships", async (req, res) => {
    const team_members = await connection.query(`SELECT
    M.Memb_ID,
    S.Stu_FName, 
    S.Stu_LName,
    M.Age,
    M.Height,
    M.Weight,
    M.Position,
    M.Memb_Type,
    T.Team_Name
    FROM Student S 
    JOIN Team_Membership M ON S.URN = M.URN
    JOIN Team T ON M.Team_ID = T.Team_ID`)
    res.render("team_members", { team_members: team_members })
})
app.get("/team_members/view/:id", async (req, res) => {

    const team_member = await connection.query(`
      SELECT 
        M.*, 
        S.Stu_FName, 
        S.Stu_LName,
        T.Team_Name,
        S.Stu_Phone
      FROM Team_Membership M
      JOIN Student S ON M.URN = S.URN
      JOIN Team T ON M.Team_ID = T.Team_ID
      WHERE M.Memb_ID = ?
    `, [req.params.id]);
  
    res.render("team_membership_view", { team_member: team_member[0] });
  
  });
app.get("/team_members/edit/:id", async (req, res) => {
    try {
        const team_member = await connection.query("SELECT * FROM TEAM_MEMBERSHIP INNER JOIN STUDENT ON STUDENT.URN = TEAM_MEMBERSHIP.URN WHERE TEAM_MEMBERSHIP.Memb_ID = ?", [req.params.id]);
        const positions = await connection.query("SELECT DISTINCT Position FROM TEAM_MEMBERSHIP");
        const membershipTypes = await connection.query("SELECT DISTINCT Memb_Type FROM TEAM_MEMBERSHIP")

        if (team_member.length > 0) {
            res.render("team_membership_edit", { team_member: team_member[0], positions: positions, membershipTypes: membershipTypes, message: "" });
        } else {
            // Handle case when team_member is not found
            res.render("team_membership_not_found");
        }
    } catch (error) {
        // Handle error appropriately
        console.error(error);
        res.status(500).send("An error occurred");
    }
})
app.post("/team_members/edit/:id", async (req, res) => {
    const positions = await connection.query("SELECT DISTINCT Position FROM TEAM_MEMBERSHIP");
    const membershipTypes = await connection.query("SELECT DISTINCT Memb_Type FROM TEAM_MEMBERSHIP")
    const updatedTeamMember = req.body;

    // Check if the updated position is among the allowed options
    const allowedPositions = ["Forward", "Midfielder", "Defender", "Goalkeeper"];
    if (!allowedPositions.includes(updatedTeamMember.Position)) {
        const team_member = await connection.query("SELECT * FROM TEAM_MEMBERSHIP INNER JOIN STUDENT ON STUDENT.URN = TEAM_MEMBERSHIP.URN WHERE TEAM_MEMBERSHIP.Memb_ID = ?", [req.params.id]);
        return res.render("team_membership_edit", {
            team_member: team_member[0],
            positions: positions,
            membershipTypes: membershipTypes,
            message: "Invalid position! Please select one of: Forward, Midfielder, Defender, Goalkeeper"
        });
    }

    try {
        // Proceed with updating the team member if the position is valid
        await connection.query("UPDATE TEAM_MEMBERSHIP SET ? WHERE TEAM_MEMBERSHIP.Memb_ID = ?", [updatedTeamMember, req.params.id]);

        // Display success message and stay on the same page
        const team_member = await connection.query("SELECT * FROM TEAM_MEMBERSHIP INNER JOIN STUDENT ON STUDENT.URN = TEAM_MEMBERSHIP.URN WHERE TEAM_MEMBERSHIP.Memb_ID = ?", [req.params.id]);
        return res.render("team_membership_edit", {
            team_member: team_member[0],
            positions: positions,
            membershipTypes: membershipTypes,
            message: "Team Member Updated!"
        });
    } catch (error) {
        console.error("Error updating team member:", error);
        res.status(500).send("An error occurred while updating team member.");
    }
});






app.post('/coaches/new', async (req, res) => {
    try {
        const { first_name, last_name, qualification_name } = req.body;

        // Insert new coach 
        const insertCoach = await connection.query(`
            INSERT INTO COACH (Coach_FName, Coach_LName) 
            VALUES (?, ?)
        `, [first_name, last_name]);

        const coachId = insertCoach.insertId; // Retrieve the inserted coach ID

        // Insert qualification for the coach
        await connection.query(`
            INSERT INTO QUALIFICATIONS (Coach_ID, Qualification_Name) 
            VALUES (?, ?)
        `, [coachId, qualification_name]);

        // Redirect back to /coaches after adding the coach
        res.redirect('/coaches');

    } catch (error) {
        console.error("Error adding a new coach:", error);
        res.status(500).send("An error occurred while adding a new coach.");
    }
});




app.get("/coaches", async (req, res) => {
    const coaches = await connection.query(`SELECT
    C.Coach_ID,
    C.Coach_FName,
    C.Coach_LName,
    GROUP_CONCAT(Q.Qualification_Name) AS Qualifications
  FROM Coach C
  JOIN Qualifications Q ON C.Coach_ID = Q.Coach_ID  
  GROUP BY C.Coach_ID;`)
    res.render("coaches", { coaches: coaches })
})
app.listen(PORT, () => {
    console.log(`application listening on http://localhost:${PORT}`)
})
