/*
    JSPWiki - a JSP-based WikiWiki clone.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.    
 */
package org.apache.wiki.workflow;

import java.util.Properties;

import org.apache.wiki.TestEngine;
import org.apache.wiki.WikiEngine;
import org.apache.wiki.api.WikiException;
import org.apache.wiki.auth.GroupPrincipal;
import org.apache.wiki.auth.WikiPrincipal;

import junit.framework.TestCase;


public class WorkflowManagerTest extends TestCase
{
    protected Workflow w;
    protected WorkflowManager wm;
    protected WikiEngine m_engine;
    
    protected void setUp() throws Exception
    {
        super.setUp();
        Properties props = new Properties();
        props.load(TestEngine.findTestProperties());
        m_engine = new TestEngine(props);
        wm = m_engine.getWorkflowManager();
        // Create a workflow with 3 steps, with a Decision in the middle
        w = new Workflow("workflow.key", new WikiPrincipal("Owner1"));
        w.setWorkflowManager(m_engine.getWorkflowManager());
        Step startTask = new TaskTest.NormalTask(w);
        Step endTask = new TaskTest.NormalTask(w);
        Decision decision = new SimpleDecision(w, "decision.editWikiApproval", new WikiPrincipal("Actor1"));
        startTask.addSuccessor(Outcome.STEP_COMPLETE, decision);
        decision.addSuccessor(Outcome.DECISION_APPROVE, endTask);
        w.setFirstStep(startTask);
        
        // Add a message argument to the workflow with the page name
        w.addMessageArgument("MyPage");
    }

    protected void tearDown() throws Exception
    {
        super.tearDown();
        m_engine.shutdown();
    }

    public void testStart() throws WikiException
    {
        // Once we start the workflow, it should show that it's started
        // and the WM should have assigned it an ID
        assertEquals(Workflow.ID_NOT_SET, w.getId());
        assertFalse(w.isStarted());
        wm.start(w);
        assertFalse(Workflow.ID_NOT_SET == w.getId());
        assertTrue(w.isStarted());
    }

    public void testWorkflows() throws WikiException
    {
        // There should be no workflows in the cache, and none in completed list
        assertEquals(0, wm.getWorkflows().size());
        assertEquals(0, wm.getCompletedWorkflows().size());
        
        // After starting, there should be 1 in the cache, with ID=1
        wm.start(w);
        assertEquals(1, wm.getWorkflows().size());
        assertEquals(0, wm.getCompletedWorkflows().size());
        Workflow workflow = wm.getWorkflows().iterator().next();
        assertEquals(w, workflow);
        assertEquals(1, workflow.getId());
        
        // After forcing a decision on step 2, the workflow should complete and vanish from the cache
        Decision d = (Decision)w.getCurrentStep();
        d.decide(Outcome.DECISION_APPROVE);
        assertEquals(0, wm.getWorkflows().size());
        assertEquals(1, wm.getCompletedWorkflows().size());
    }
    
    public void testRequiresApproval()
    {
        // Test properties says we need approvals for workflow.saveWikiPage & workflow.foo
        assertFalse(wm.requiresApproval("workflow.saveWikiPage"));
        assertTrue(wm.requiresApproval("workflow.foo"));
        assertTrue(wm.requiresApproval("workflow.bar"));
    }

    public void testGetApprover() throws WikiException
    {
        // Test properties says workflow.saveWikiPage approver is GP Admin; workflow.foo is 'janne'
        assertEquals(new WikiPrincipal("janne", WikiPrincipal.LOGIN_NAME), wm.getApprover("workflow.foo"));
        assertEquals(new GroupPrincipal("Admin"), wm.getApprover("workflow.bar"));
        
        // 'saveWikiPage' workflow doesn't require approval, so we will need to catch an Exception
        try 
        {
            assertEquals(new GroupPrincipal("Admin"), wm.getApprover("workflow.saveWikiPage"));
        }
        catch (WikiException e)
        {
            // Swallow
            return;
        }
        // We should never get here
        fail("Workflow.bar doesn't need approval!");
    }

}