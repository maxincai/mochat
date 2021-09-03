<?php

declare(strict_types=1);
/**
 * This file is part of MoChat.
 * @link     https://mo.chat
 * @document https://mochat.wiki
 * @contact  group@mo.chat
 * @license  https://github.com/mochat-cloud/mochat/blob/master/LICENSE
 */
namespace MoChat\Plugin\RoomMessageBatchSend\Logic;

use Hyperf\Contract\StdoutLoggerInterface;
use Hyperf\DbConnection\Db;
use Hyperf\Di\Annotation\Inject;
use League\Flysystem\Filesystem;
use MoChat\App\WorkContact\Contract\WorkContactRoomContract;
use MoChat\App\WorkEmployee\Contract\WorkEmployeeContract;
use MoChat\App\WorkRoom\Contract\WorkRoomContract;
use MoChat\Framework\Constants\ErrorCode;
use MoChat\Framework\Exception\CommonException;
use MoChat\Plugin\RoomMessageBatchSend\Contract\RoomMessageBatchSendContract;
use MoChat\Plugin\RoomMessageBatchSend\Contract\RoomMessageBatchSendEmployeeContract;
use MoChat\Plugin\RoomMessageBatchSend\Contract\RoomMessageBatchSendResultContract;
use MoChat\Plugin\RoomMessageBatchSend\QueueService\StoreApply;

class StoreLogic
{
    /**
     * @Inject
     * @var RoomMessageBatchSendContract
     */
    private $roomMessageBatchSend;

    /**
     * @Inject
     * @var RoomMessageBatchSendEmployeeContract
     */
    private $roomMessageBatchSendEmployee;

    /**
     * @Inject
     * @var RoomMessageBatchSendResultContract
     */
    private $roomMessageBatchSendResult;

    /**
     * @Inject
     * @var WorkEmployeeContract
     */
    private $workEmployee;

    /**
     * @Inject
     * @var WorkRoomContract
     */
    private $workRoom;

    /**
     * @Inject
     * @var WorkContactRoomContract
     */
    private $workContactRoom;

    /**
     * @Inject
     * @var StdoutLoggerInterface
     */
    private $logger;

    public function handle(array $params, array $user): bool
    {
        $corpId      = $user['corpIds'][0];
        $employeeIds = (array) $params['employeeIds'];

        ## 获取用户成员
        $employees = $this->workEmployee->getWorkEmployeesByIdCorpIdStatus($corpId, $employeeIds, 1, ['id', 'wx_user_id']);
        if (count($employees) !== count($employeeIds)) {
            throw new CommonException(ErrorCode::INVALID_PARAMS);
        }
        ## 入库
        Db::beginTransaction();
        try {
            $batchId      = $this->roomMessageBatchSend->createRoomMessageBatchSend([
                'corp_id'       => $corpId,
                'user_id'       => $user['id'],
                'user_name'     => $user['name'] ?: $user['phone'],
                'batch_title'   => $params['batchTitle'],
                'content'       => json_encode($params['content'], JSON_UNESCAPED_UNICODE),
                'send_way'      => $params['sendWay'],
                'definite_time' => $params['definiteTime'],
                'created_at'    => date('Y-m-d H:i:s'),
            ]);

            $employeeTotal = 0;
            $roomTotal     = 0;
            foreach ($employees as $employee) {
                ++$employeeTotal;
                ## 获取成员客户
                $rooms = $this->workRoom->getWorkRoomsByOwnerId($employee['id'], ['id', 'name', 'wx_chat_id', 'create_time']);
                $roomTotal += count($rooms);
                ## 扩展多条消息
                foreach ($params['content'] as $content) {
                    ## 客户群
                    $roomTotal = 0;
                    foreach ($rooms as $room) {
                        $this->roomMessageBatchSendResult->createRoomMessageBatchSendResult([
                            'batch_id'          => $batchId,
                            'employee_id'       => $employee['id'],
                            'room_id'           => $room['id'],
                            'room_name'         => $room['name'],
                            'room_create_time'  => $room['createTime'],
                            'room_employee_num' => $this->workContactRoom->countWorkContactRoomByRoomIds([$room['id']]),
                            'chat_id'           => $room['wxChatId'],
                            'created_at'        => date('Y-m-d H:i:s'),
                        ]);
                        ++$roomTotal;
                    }
                    ## 成员
                    $this->roomMessageBatchSendEmployee->createRoomMessageBatchSendEmployee([
                        'batch_id'        => $batchId,
                        'employee_id'     => $employee['id'],
                        'wx_user_id'      => $employee['wxUserId'],
                        'send_room_total' => $roomTotal,
                        'content'         => json_encode($content, JSON_UNESCAPED_UNICODE),
                        'created_at'      => date('Y-m-d H:i:s'),
                        'last_sync_time'  => date('Y-m-d H:i:s'),
                    ]);
                }
            }
            $this->roomMessageBatchSend->updateRoomMessageBatchSendById($batchId, [
                'sendEmployeeTotal' => $employeeTotal,
                'sendRoomTotal'     => $roomTotal,
            ]);
            Db::commit();
        } catch (\Throwable $e) {
            Db::rollBack();
            $this->logger->error(sprintf('%s [%s] %s', '客户群消息群发创建失败', date('Y-m-d H:i:s'), $e->getMessage()));
            $this->logger->error($e->getTraceAsString());
            throw new CommonException(ErrorCode::SERVER_ERROR, '客户群消息群发创建失败');
        }

        if ((int)$params['sendWay'] === 1) {
            make(StoreApply::class)->handle($batchId);
        }
        return true;
    }
}
