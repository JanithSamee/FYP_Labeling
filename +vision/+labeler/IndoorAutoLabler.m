classdef IndoorAutoLabler < vision.labeler.AutomationAlgorithm  & vision.labeler.mixin.Temporal
    
    properties(Constant)
        Name = 'Indoor Auto Labeler';
        Description = 'IndoorAutoLabler class, inheriting AutomationAlgorithm,  for labeling indoor scenes using 4-layer LiDAR.';
        UserDirections = {...
            ['Automation algorithms are a way to automate manual labeling ' ...
            'tasks. This AutomationAlgorithm is a template for creating ' ...
            'user-defined automation algorithms. Below are typical steps' ...
            'involved in running an automation algorithm.'], ...
            ['Run: Press RUN to run the automation algorithm. '], ...
            ['Review and Modify: Review automated labels over the interval ', ...
            'using playback controls. Modify/delete/add ROIs that were not ' ...
            'satisfactorily automated at this stage. If the results are ' ...
            'satisfactory, click Accept to accept the automated labels.'], ...
            ['Change Settings and Rerun: If automated results are not ' ...
            'satisfactory, you can try to re-run the algorithm with ' ...
            'different settings. In order to do so, click Undo Run to undo ' ...
            'current automation run, click Settings and make changes to ' ...
            'Settings, and press Run again.'], ...
            ['Accept/Cancel: If results of automation are satisfactory, ' ...
            'click Accept to accept all automated labels and return to ' ...
            'manual labeling. If results of automation are not ' ...
            'satisfactory, click Cancel to return to manual labeling ' ...
            'without saving automated labels.']};
    end
    
    properties
        labelCount=0;
        startROI;
        prevROI=[];
        prevFrame;
        prevSubFrame;
    end
    
    methods (Static)
        function isValid = checkSignalType(signalType)
            isValid = (signalType == vision.labeler.loading.SignalType.PointCloud);
        end
    end
    
    methods
        function isValid = checkLabelDefinition(algObj, labelDef)
            disp(['Executing checkLabelDefinition on label definition "' labelDef.Name '"'])

             if labelDef.Type == labelType("Cuboid")
                algObj.labelCount = algObj.labelCount + 1;
             end
             if(algObj.labelCount~=0)
                 isValid = true;
             else
                 isValid = false;
             end
            
        end
        
        function isReady = checkSetup(algObj,labelsToAutomate)
            disp('Executing checkSetup')
           
            numROIs = height(labelsToAutomate);
            
            assert(numROIs >= 1, ...
                'You must create a ROI at start!');

             isReady = true;
        end
        
        function settingsDialog(algObj)
            disp('Executing settingsDialog')
            % Add your implementation here if needed
        end
    end
    
    methods
        function initialize(algObj, frame,labelsToAutomate)
            disp('Executing initialize on the first image frame')
            algObj.startROI= labelsToAutomate;
            algObj.prevROI= labelsToAutomate.Position(1,:);
           algObj.prevFrame = pcdownsample(frame, 'gridAverage', 0.1);
            xLimits = [-1, 4]; % Define the limits along the x-axis
            yLimits = [-4, 4]; % Define the limits along the y-axis
            zLimits = [-0.5, 1]; % Define the limits along the z-axis
            indices = findPointsInROI(algObj.prevFrame, [xLimits; yLimits; zLimits]);
            algObj.prevSubFrame = select(algObj.prevFrame, indices);

        end
            
        %Automation
        function autoLabels = run(algObj, frame)
            disp(frame);
            ROI_pose= algObj.prevROI;
            rframe = pcdownsample(frame, 'gridAverage', 0.01);
            
            
            xLimits = [-1, 4]; % Define the limits along the x-axis
            yLimits = [-4, 4]; % Define the limits along the y-axis
            zLimits = [-0.5, 1]; % Define the limits along the z-axis
            indices = findPointsInROI(rframe, [xLimits; yLimits; zLimits]);
            subPtCloud = select(rframe, indices);
            
            
            normals = pcdenoise(algObj.prevSubFrame);
            centroid = mean(normals.Location);
            
            
            normalsnew = pcdenoise(subPtCloud);
            centroidnew = mean(normalsnew.Location);

            
            [tform, ~, ~] = pcregistericp(algObj.prevSubFrame, subPtCloud);

            % Extract rotation and translation
            R = tform.T(1:3, 1:3); % Rotation matrix
            t = tform.T(4, 1:3)'; % Translation vector
            
            % Define the original ROI parameters
            xctr = ROI_pose(:,1);
            yctr = ROI_pose(:,2);
            zctr = ROI_pose(:,3);
            xlen = ROI_pose(:,4);
            ylen = ROI_pose(:,5);
            zlen = ROI_pose(:,6);
            xrot = ROI_pose(:,7);
            yrot = ROI_pose(:,8);
            zrot = ROI_pose(:,9);
            
               % Apply translation to center coordinates
            new_xctr = xctr +t(1);
            new_yctr = yctr +t(2);
            new_zctr = zctr +t(3);

           
            % registration
            new_xrot = xrot-atan2d(-R(2,3), R(3,3))*0.1;
            new_yrot = yrot-asind(R(1,3))*0.1;
            new_zrot = zrot-atan2d(-R(1,2), R(1,1))*0.1;

            
            algObj.prevFrame = pcdownsample(frame, 'gridAverage', 0.01);
            algObj.prevSubFrame=subPtCloud;
            algObj.prevROI=[new_xctr, new_yctr, new_zctr, xlen, ylen, zlen, new_xrot, new_yrot, new_zrot];
            autoLabels = struct('Name', 'chair', 'Type', labelType('Cuboid'), 'Position', [new_xctr, new_yctr, new_zctr, xlen, ylen, zlen, new_xrot, new_yrot, new_zrot]);
%         autoLabels=struct();
        end
        
        function terminate(algObj)
            disp('Executing terminate')
            % Add your implementation here if needed
        end
    end
end
