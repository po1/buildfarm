<?xml version='1.0' encoding='UTF-8'?>
<project>
  <actions/>
  <description>Generated job to create binary debs for dry stack "@(PACKAGE)". DO NOT EDIT BY HAND. Generated by catkin-debs/scripts/create_release_job(s).py for @(USERNAME) at @(TIMESTAMP)</description>
  <logRotator>
    <daysToKeep>30</daysToKeep>
    <numToKeep>10</numToKeep>
    <artifactDaysToKeep>30</artifactDaysToKeep>
    <artifactNumToKeep>-1</artifactNumToKeep>
  </logRotator>
  <keepDependencies>false</keepDependencies>
  <properties>
  </properties>
  <scm class="hudson.scm.SubversionSCM">
    <locations>
      <hudson.scm.SubversionSCM_-ModuleLocation>
        <remote>https://code.ros.org/svn/release/trunk</remote>
        <local>release</local>
      </hudson.scm.SubversionSCM_-ModuleLocation>
      <hudson.scm.SubversionSCM_-ModuleLocation>
        <remote>https://code.ros.org/svn/ros/stacks/ros_release/trunk</remote>
        <local>ros_release</local>
      </hudson.scm.SubversionSCM_-ModuleLocation>
    </locations>
    <excludedRegions></excludedRegions>
    <includedRegions></includedRegions>
    <excludedUsers></excludedUsers>
    <excludedRevprop></excludedRevprop>
    <excludedCommitMessages></excludedCommitMessages>
    <workspaceUpdater class="hudson.scm.subversion.UpdateUpdater"/>
  </scm>
  <assignedNode>debbuild</assignedNode>
  <canRoam>false</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>true</blockBuildWhenUpstreamBuilding>
  <authToken>RELEASE_BUILD_DEBS</authToken>
  <triggers class="vector"/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
@[if not IS_METAPACKAGES]@
    <hudson.plugins.groovy.SystemGroovy plugin="groovy@@1.12">
      <scriptSource class="hudson.plugins.groovy.StringScriptSource">
        <command>
// VERFIY THAT NO UPSTREAM PROJECT IS BROKEN
import hudson.model.Result

project = Thread.currentThread().executable.project

for (upstream in project.getUpstreamProjects()) {
	abort = upstream.getNextBuildNumber() == 1

	if (!abort) {
		lb = upstream.getLastBuild()
		if (!lb) continue

		r = lb.getResult()
		if (!r) continue

		abort = r.isWorseOrEqualTo(Result.FAILURE)
	}

	if (abort) {
		println "Aborting build since upstream project '" + upstream.name + "' is broken"
		throw new InterruptedException()
	}
}
</command>
      </scriptSource>
      <bindings/>
      <classpath/>
    </hudson.plugins.groovy.SystemGroovy>
@[end if]@
    <hudson.tasks.Shell>
      <command>@(COMMAND)</command>
    </hudson.tasks.Shell>
@[if not IS_METAPACKAGES]@
    <hudson.plugins.groovy.SystemGroovy plugin="groovy@@1.12">
      <scriptSource class="hudson.plugins.groovy.StringScriptSource">
        <command>
// CHECK FOR "HASH SUM MISMATCH" AND RETRIGGER JOB
import java.io.BufferedReader
import java.util.regex.Matcher
import java.util.regex.Pattern

import hudson.model.Cause
import hudson.model.Result

build = Thread.currentThread().executable

// search build output for hash sum mismatch
r = build.getLogReader()
br = new BufferedReader(r)
pattern = Pattern.compile(&quot;.*W: Failed to fetch .* Hash Sum mismatch.*&quot;)
def line
while ((line = br.readLine()) != null) {
	if (pattern.matcher(line).matches()) {
		println "Aborting build due to 'hash sum mismatch'. Immediately rescheduling new build..."
		build.project.scheduleBuild(new Cause.UserIdCause())
		throw new InterruptedException()
	}
}
</command>
      </scriptSource>
      <bindings/>
      <classpath/>
    </hudson.plugins.groovy.SystemGroovy>
@[end if]@
  </builders>
  <publishers>
    <hudson.tasks.BuildTrigger>
      <childProjects>@(','.join(CHILD_PROJECTS))</childProjects>
      <threshold>
        <name>SUCCESS</name>
        <ordinal>0</ordinal>
        <color>BLUE</color>
      </threshold>
    </hudson.tasks.BuildTrigger>
    <hudson.tasks.Mailer>
      <recipients></recipients>
      <dontNotifyEveryUnstableBuild>true</dontNotifyEveryUnstableBuild>
      <sendToIndividuals>false</sendToIndividuals>
    </hudson.tasks.Mailer>
  </publishers>
  <buildWrappers/>
</project>
