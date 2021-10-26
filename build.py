import os

from distutils.dir_util import copy_tree
from builder import BuildDirectory


copy_tree('src', 'dist')
build_live = BuildDirectory('dist')
build_live.remove_active_flows(os.path.join('.', 'dist/flows-live', 'flows'))

build_live.remove_elements(os.path.join('.', 'src', 'applications'), 'profileActionOverrides', 'profile', 'Minimum Access - Salesforce')

build_live.remove_elements(os.path.join('.', 'src', 'profiles'), 'userPermissions', 'name', 'ManageSandboxes')
build_live.remove_elements(os.path.join('.', 'src', 'profiles'), 'userPermissions', 'name', 'ManageReleaseUpdates')
build_live.remove_elements(os.path.join('.', 'src', 'profiles'), 'userPermissions', 'name', 'SkipIdentityConfirmation')
build_live.remove_elements(os.path.join('.', 'src', 'profiles'), 'userPermissions', 'name', 'ManageCssUsers')
build_live.remove_elements(os.path.join('.', 'src', 'profiles'), 'userPermissions', 'name', 'ManagePartners')
build_live.remove_elements(os.path.join('.', 'src', 'profiles'), 'userPermissions', 'name', 'SendExternalEmailAvailable')
