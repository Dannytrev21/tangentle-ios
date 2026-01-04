
- create a command called /plan-feature-initial that works like /plan-feature, but first asks me questions about what I need that I have to fill out to then give /plan-feature so that it has a complete idea of what I want and doesn't assume anything. I will give it my plan, it will analyze it using tree of thought, similar to /plan-feature, and identifies gaps in understanding then returns me an optimized prompt to give /plan-feature with blanks for me to enter information that it's missing. 

- Create a command /plan-feature-review this is an extention of the /plan-feature, it basically does the same thing but it after the /plan-feature command. It reviews the plan created, critiques it if needed, and adds any additional steps, adds additional detail or edits the the steps, the adr, context, plan. It can also reprioritize the steps as well. 


- Make sure it's testable unit, integration, UI, Snapshot testsswift-snapshot-testing

- Help me update the claude command planning system: `/plan-feature-initial`, `/plan-feature`, `/plan-feature-review`, /plan-prompts, plan-rollback, plan-verify, and plan-next feature. To incorporate the newly added prompt engineering commands (/chain-of-code, /got, /least-to-most, /ps-plus, /react, /reflexion, /self-consistency, /self-refine, /tdd, /tot) and to automatically pick the correct prompting technique for the problem and step I am on. This should work automatically without me having to remember which type of prompt engineering goes to which type of problem or step. Feel free to add additional steps or edit the `/plan-*` steps if needed. The idea is to first plan out the best prompt and techniques, then give the planning prompt, then have it plan all the steps and setup, then write up the best prompts for each step using the best prompt engineering, then reviewing the plan or making it better, then implement the steps using the best ai agent techniques to catch mistakes and ensure the highest quality code, reviewing and testing itself, make sure it self corrects. These problems should eachc have their own workflow: debug, ideation, UI, UX, system design, refactor, migration, new feature, algorithm solving, documentation, etc. Feel free to use external tools or create scripts, breaking up the problems, or anything else to make this automatic or reduce calls to claude without reducing the quality of the work. 

- Make sure all the tests are passing

Use Graph of Thoughts instead of Tree of Thought

- Use google gemini where possible

- Plan initial should have a document that can be referenced for the idea of my plan and once I answer all the question it is updated, I will copy and paste this into the plan-feature, it will also be referenced by the plan-review. 

- After the end of each plan next compact the conversation but keep necessry stuff.

- another prompt like called /plan-feature-quality this is performed after /plan-feature-review. This should look at the steps created and the plan and come up with a testing plan for each step and add a final comphrenesive testing and code quality step. You also need to remove the testing portion of /plan-feature and /plan-feature-review (if any) and mention that this will be done in a later phase. Help me update the rest of the `/plan-feature-*` and `/plan-next` and /plan-prompt` system as well. This command will help provide feedback for each step to the AI agent so that it catches it's mistakes fast and writes high quality code using best practices. 

- Help me figure out what else my app/project needs to shift left and be well managed write high quality code, catch bugs, etc. things like swiftlinting, pipeline automated testing, github actions, precommit clang static analyzer, Automated PR reviews, debug logging etc. 

brew install swiftlint, Clang Static Analyzer (precommit), help me setup pre commit github actions, etc. 

Overly verbose debugging and logging for now to help identify issues quickly in the development phase. 

Documentation. 



- Make sure the tasks, projects, goals, events, subtasks, routines, focus modes, habits are all very customizable, they should be able to link up to each other. You should be able to turn on and off settings to change how they behave or even if they show up, or what information they display. Don't worry about the UI right now, just make sure the data modeling and infrastructure is there. 

- There needs to be a place to add a description to the projects, tasks, goals, problemtypes, strategies. 

- The main screen UI should change depending on the focus mode. So if I'm currently in a morning routine that should be shown, but if I am at work then a task system should be shown (or pomodoro if I enable that). 

- Eventually the strategies will be shared across others

- Add Google calendar or iOS calendar support 

- On boarding, goals and projects

- Schedule in the middle

- I want to make sure the center screen changes depending on the current focusmode. So for example. In the morning there would be a morning routine where you have certain steps to get up and do things. Then there can be a morning planning focus mode, where it has you create (or find 3 tasks) that will be your top 3 priorities. You can edit it to add things like morning gratitude, a daily motivation quote, your schedule, habits you want to check off, or notes for you to write. Then it might go into focus mode where you it shows you tasks events for work only, and then you can add an end of work shutdown routine where you can also customize it like the morning planning routine. Then there is an evening routine, a bed time routine. This can also change on the weekends to have your own routines and focus modes. These can be templated. 

- Can create own type of thing includes things for 3 tasks, maybe gratidude, check off routines, filled in tasks or empty fields for tasks 

- Something like hybernate or spring jpa repository that handles complex relationships 

- colors: Terracotta + Ochre + Olive + Burgundy

- Custamizable "task"


- Work on next available task. 

- Only show the rest of the day, not the previous. 

- New task, help me add the priority, the project/list, tags,

- Strategies

- batch jobs together

- breaks.

- settings page.

- sanely.ai 

- Take notes, organize them. 









